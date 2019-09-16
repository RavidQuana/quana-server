# == Schema Information
#
# Table name: notifications
#
#  id                   :bigint           not null, primary key
#  sender_id            :integer
#  sender_type          :string
#  receiver_id          :integer
#  receiver_type        :string
#  notification_type_id :integer
#  body                 :string(4096)
#  linkable_id          :integer
#  linkable_type        :string
#  delivery_status      :integer          default("received")
#  is_visible           :boolean          default(TRUE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Notification < ApplicationRecord
	belongs_to :sender, polymorphic: true, optional: true
	belongs_to :receiver, polymorphic: true

	belongs_to :notification_type
	belongs_to :linkable, polymorphic: true, optional: true

	enum delivery_status: { received: 0, seen: 1, read: 2 }

	# system notifications
	scope :system, -> { where(sender_id: nil) }

	# unseen\unread notifications
	scope :unseen, -> { where('delivery_status < ?', Notification.delivery_statuses[:seen]) }
	scope :unread, -> { where('delivery_status < ?', Notification.delivery_statuses[:read]) }
	scope :visible, -> { where(is_visible: true) }

	after_create :set_body

	def payload
		{
			notification_id: id,
			client_action: notification_type.client_action_name,
			linkable_id: linkable_id,
			notification_type_id: notification_type_id
		}.merge(linkable&.context)
	end

	private

	# set the final body text based on the pattern
	def set_body
		pattern = notification_type.body_pattern

		keys = pattern.scan(/%\{(.*?)\}/).flatten

		values = keys.reduce({}) { |result, k|
			resource, attribute = k.split('.', 2)
			instance = self.try(resource)
			v = apply_formatting(attribute, instance ? instance.try(attribute) : nil)

			result.merge({ k => v })
		}

		# replace nil values with empty string
		values.each { |k, v| v.blank? ? values[k] = '' : nil }

		self.body = pattern % values.symbolize_keys
		self.save
	end

	# apply custom formatting to specific body pattern key\values
	def apply_formatting(k, v)
		if v.is_a?(Date) || v.is_a?(Time) || v.is_a?(DateTime)
			I18n.l(v, format: :notification)
		else
			return v
		end
	end

end
