module ActiveAdmin
	module Devise
		class OtpController < DeviseController
			include ::ActiveAdmin::Devise::Controller

			def index
				user = signed_in_resource

				issuer = "#{Settings.project_name} (#{Rails.env})"
				label = "#{issuer}:#{user.email}"

		    	user.otp_secret ||= resource_class.generate_otp_secret
		    	user.save 

		    	uri = user.otp_provisioning_uri(label, issuer: issuer)
		    	@qrcode = RQRCode::QRCode.new(uri)
			end

			def setup
				user = signed_in_resource

				unless user.validate_and_consume_otp!(params[:otp][:code])
					redirect_to otp_setup_path, flash: { error: I18n.t('devise.failure.otp') } and return
				end
				
				user.otp_required_for_login = true
				user.save

				redirect_to root_path
			end
		end
	end
end