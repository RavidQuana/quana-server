module UserHelpers
  extend ActiveSupport::Concern

  included do
    helpers do

      params :user_attributes do
        optional :first_name, type: String, allow_blank: false, desc: "The user's first name"
        optional :last_name, type: String, allow_blank: false, desc: "The user's last name"
        optional :cannabis_use_years, type: Integer, allow_blank: false, desc: "The user's canabbis user in years"
        optional :cannabis_use_monthes, type: Integer, allow_blank: false, desc: "The user's canabbis user in monthes"
        optional :gender, type: Integer, allow_blank: false, desc: "The user's canabbis user in monthes"
        optional :cannabis_use_frequency, type: String, allow_blank: false, desc: "The user's canabbis use frequency"
        optional :blood_sugar_medications, type: Virtus::Attribute::Boolean, allow_blank: false, desc: "The user's takes blood sugar medication"
        optional :birth_date, type: Date, coerce_with: ->(v) { Date.strptime(v, "%m/%d/%Y") rescue false }, desc: "The user's birthdate"
        optional :treatment_ids, type: Array[Integer], desc: "An array of valid treatment ids"
        optional :user_symptoms, type: Array[JSON] do
          use :user_symptom_attributes
        end
      end
      
      params :user_symptom_attributes do 
				optional :id, type: Integer, desc: "A valid user symptom id"
				optional :symptom_id, type: Integer, allow_blank: false, desc: "A valid symptom id"
				optional :severity, type: Integer, allow_blank: false, desc: "Severity value"
			end

      params :device_attributes do
        optional :device_token, type: String, desc: "The user's device token"
        optional :os_type, type: Integer, values: Device.os_types.values,
                 desc: "The user's device os type (#{Device.os_types})"
        all_or_none_of :device_token, :os_type
        optional :device_type, type: String, desc: "The user's device type"
        optional :os_version, type: String, desc: "The user's device os version"
        optional :app_version, type: String, desc: "The user's app version"
        optional :is_sandbox, type: Virtus::Attribute::Boolean, desc: "(iOS Devices Only) Indicates
	        		whether the device token is a sandbox token or a release one"
      end

      def attach_device
        if params[:device_token].present?
          device = @current_user.devices.find_or_initialize_by(device_token: params[:device_token], os_type: params[:os_type])
          device.assign_attributes({device_type: params[:device_type], os_version: params[:os_version],
                                    app_version: params[:app_version], is_sandbox: params[:is_sandbox]}.reject { |k, v| !params.has_key?(k) })
          device.save
        end
      end
    end
  end
end