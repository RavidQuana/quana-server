class NotificationSender
	require 'fcm'
	include Sidekiq::Worker
	sidekiq_options queue: 'notifications', retry: false

	@@semaphore = Mutex.new

	# sends a notification of type [notification_type] to the provided list of receivers
	#
	# sender_id\sender_type 		the sending user; leave blank for system notifications
	# receivers						a hash in the format { ClassName => [ids] } specifying the polymorphic list of receivers
	# notification_type				a valid notification type id
	# linkable_id					a valid linkable id matching the required linkable type (specified as part of the notification type) 
	def perform(sender_id, sender_type, receivers, notification_type, linkable_id)
		nt = NotificationType.find_by(name: notification_type)
		return if nt.blank?

		linkable = get_linkable(nt, linkable_id) if linkable_id.present?

		sandbox_apns_client, production_apns_client = init_apns_clients
		fcm_client = init_fcm_client
		sms_client = init_sms_client

		receivers.each do |type, ids|
			resource = type.classify.constantize

    		# whenever working with large collections, make sure to iterate in batches
    		# otherwise Rails will attempt to instantiate *all* records at once, which will inevitably penalize memory usage 
			resource.where(id: ids).find_each(batch_size: 250) do |receiver|
				set_locale(receiver)
				notification = create_and_persist_notification(sender_id, sender_type, receiver, nt, linkable)

				# skip if no new notifications were created or notification text is blank
				next unless notification.present? && notification.body.present?

    			# skip if current receiver disabled notifications
    			next unless receiver.allow_notifications?(notification_type)

				begin
					send_via_sms(sms_client, receiver, notification) if nt.send_sms

					if nt.send_push
						# skip if current receiver doesn't have any devices attached
						next unless receiver.devices.any? 

						ios_devices = receiver.devices.ios.active
						send_to_ios_device(sandbox_apns_client, production_apns_client,
							ios_devices, notification) if ios_devices.any?

						android_devices = receiver.devices.android.active
						send_to_android_device(fcm_client, android_devices, notification) if android_devices.any?
					end
				rescue => e
					Bugsnag.notify(e)
					next # continue looping
				end
			end
		end
	end

	def get_linkable(notification_type, linkable_id)
		linkable_type = notification_type.required_linkable_type
		return if linkable_type.blank?

		begin
			return linkable_type.constantize.find_by(id: linkable_id)
		rescue
			return nil
		end
	end

    # use the same connection for all ios notifications (Apple standard)
    # make sure to send the notifications to both sandbox and release tokens
	def init_apns_clients
		begin
			env = Rails.env.production? ? 'production' : 'staging'
			cert = "lib/assets/certificate-#{env}.pem"

			production_apns_client = Houston::Client.production
			production_apns_client.certificate = File.read(cert)

			sandbox_apns_client = Houston::Client.development
			sandbox_apns_client.certificate = File.read(cert)

			return sandbox_apns_client, production_apns_client
		rescue => e
			puts "Error initializing APNS client. Skipping iOS notifications for this batch."
		end

		return nil
	end

	def init_fcm_client
		begin
			return FCM.new(Rails.application.secrets.fcm_key)
		rescue => e
			puts "Error initializing FCM client. Skipping Android notifications for this batch."
		end

		return nil
	end

	def init_sms_client
		begin
			case Settings.sms_client_type
			when 'twilio'
				return Twilio::REST::Client.new(
					Rails.application.credentials.sms_client_username,
					Rails.application.credentials.sms_client_password
				)
			when '019'
				return SMS019::REST::Client.new(
					Rails.application.credentials.sms_client_username,
					Rails.application.credentials.sms_client_password,
					{ sender_id: Settings.sms_client_sender_id }
				)
			end
		rescue => e
			puts "Error initializing SMS client. Skipping SMS notifications for this batch."
		end

		return nil
	end

	# set this to support multilingual notifications
	def set_locale(receiver)
		I18n.locale = receiver.try(:locale) || I18n.default_locale
	end

	# change to TRUE to avoid sending multiple notifications of the same type to the same user
	# see create_and_persist_notification for the actual logic
	# NOTE: the above logic could potentially be re-written to support time-based aggregations,
	# and Facebook style notifications (e.g. "N+ people liked your post")
	def should_aggregate
		false
	end

	# setup badge logic (currently defaults to 1, but should probably match the user's unseen notifications count)
	def get_badge
		1
	end

	def notification_exists(receiver, notification_type, linkable_id)
		Notification.exists?(
			receiver: receiver,
			notification_type: notification_type,
			linkable: linkable
		)
	end

	def create_and_persist_notification(sender_id, sender_type, receiver, notification_type, linkable)
		notification = nil

    	# use a thread lock to prevent stale reads and race conditions
    	# (i.e. multiple threads attempting to create the same notification object in parallel)
		@@semaphore.synchronize do
			return if should_aggregate && notification_exists(receiver, notification_type, linkable)

			notification = Notification.new(
				sender_id: sender_id,
				sender_type: sender_type,
				receiver: receiver,
				notification_type: notification_type,
				linkable: linkable
			)

			notification.save
		end

		return notification
	end

	def send_to_android_device(fcm, devices, notification)
		success = false

		if fcm
			payload = Hash.new

			payload[:message] = notification.body
			notification.payload.each do |k, v|
				payload[k] = v
			end

			options = {
					'data' => payload,
					'collapse_key' => 'updated_state'
			}

			response = fcm.send_notification(devices.map(&:device_token), options)
			response_hash = JSON.parse(response[:body].gsub('\"', '"'))

			# count as successful if at least one device received the message
			if response_hash['success'].to_i > 0
				success = true
			end

			# parse full response
			response_hash['results'].each_with_index do |status, index|
				device = devices[index]

				if status.has_key?('error')
					device.failed_attempts += 1
					device.save

					puts "Error: failed to send Android push notification (#{status['error']})."
				else
					device.failed_attempts = 0

					if status.has_key?('registration_id') && status['registration_id'].present?
						# check for device token updates
						device.device_token = status[:registration_id]
					end

					device.save
				end
			end
		end

		return success
	end

	def send_to_ios_device(sandbox_apns, production_apns, devices, notification)
		success = false

		if sandbox_apns && production_apns
			devices.each do |device|
				note = Houston::Notification.new(device: device.device_token)

				note.sound = 'default'
				note.badge = get_badge
				note.content_available = true
				note.alert = notification.body
				notification.payload.each do |k, v|
					note.custom_data[k.to_s] = v
				end

				if device.is_sandbox
					sandbox_apns.push(note)
				else
					production_apns.push(note)
				end

				if note.error
					device.failed_attempts += 1
					device.save
					puts "Error: failed to send iOS push notification (#{note.error})."
				else
					# count as successful if at least one device received the message
					success = true

					device.failed_attempts = 0
					device.save
				end
			end
		end

		return success
	end

	def send_via_sms(sms_client, receiver, notification)
		if sms_client
			case Settings.sms_client_type
			when 'twilio'
				sms_client.messages.create(
						from: Settings.sms_client_sender_id,
						to: receiver.phone_number,
						body: notification.body
				)
			when '019'
				sms_client.send(
						notification.body,
						[receiver.phone_number]
				)
			end
		end

		return false
	end
end