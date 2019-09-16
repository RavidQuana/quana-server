module UserHelpers
  extend ActiveSupport::Concern

  included do
    helpers do

      params :user_attributes do

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