module CodeValidatable
  	extend ActiveSupport::Concern
    require 'twilio-ruby'

    included do
    	has_many :activation_codes, inverse_of: :owner, as: :owner, dependent: :destroy

    	before_validation :normalize_phone_number
		
		validates :phone_number, presence: true, uniqueness: true
    end

  	def send_activation_code(i18n_msg_key)
  		return true if phone_number == Settings.qa_phone

  		code = generate_code
    	if activation_codes.create(code: code, expires_at: 1.hour.since)
	    	# remove old activation codes
	    	old_code_ids = activation_codes.order(created_at: :desc).pluck(:id)
            old_code_ids.shift(Settings.max_codes_per_user)
	    	activation_codes.where(id: old_code_ids).delete_all

			begin
				client = Twilio::REST::Client.new(
					Rails.application.credentials.sms_client_username, 
					Rails.application.credentials.sms_client_password
				)

				client.api.account.messages.create({ 
					from: Settings.sms_client_sender_id, 
					to: phone_number, 
					body: I18n.t(i18n_msg_key, code: code) 
				})

				return true
			rescue => e
				Bugsnag.notify(e)
				return false
			end
	    end

	    return false
    end	

    def validate_code(code)
    	return true if phone_number == Settings.qa_phone && code == Settings.qa_code

    	activation = activation_codes.active.where(code: code).first

    	if activation.present?
            return activation_codes.count == activation_codes.delete_all
    	end

    	activation_codes.update_all('tries_count = tries_count + 1')
    	activation_codes.where('tries_count >= ?', Settings.max_tries_count).delete_all

    	return false
    end

    def formatted_phone_number
        Phonelib.parse(phone_number, Settings.default_country_code).national
    end

	private
		def normalize_phone_number
			self.phone_number = Phonelib.parse(phone_number, Settings.default_country_code).full_e164
		end	

		def generate_code
	  		code = []
	  		while code.length < Settings.code_length
	  			code << SecureRandom.random_number(9).to_s
			end

			code.join
		end       
end