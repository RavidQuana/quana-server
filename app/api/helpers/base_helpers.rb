module BaseHelpers
  extend ActiveSupport::Concern

  included do
    helpers do
      def render_error(code, message, debug = '')
        error!({ code: code, message: message, data: [] }, code)
      end

      def render_success(object, entity = nil, entity_params = { })
        present :code, status
        present :message, 'ok'
        present :data, object, entity_params.merge({ with: entity })
      end

      def current_user
        return nil if headers['X-Auth-Token'].blank?
        @current_user ||= User.active.find_by(token: headers['X-Auth-Token'])
      end

      def restrict_access
        return (render_error RESPONSE_CODES[:unauthorized], 'Unauthorized') unless current_user.present?
        @current_user.update_attributes(last_activity_at: Time.current)
      end

      def set_locale
        if params[:locale].present?
          if params[:locale] == 'iw'
            l = 'he'
          else
            l = params[:locale]
          end
        end

        I18n.locale = l || I18n.default_locale
      end

      def get_code(resource, phone_number)
        resource_name = resource.name.underscore
              phone = Phonelib.parse(phone_number, Settings.default_country_code)
              @current_user = resource.find_by(phone_number: phone.full_e164)

              if @current_user.blank?
                  @current_user = resource.new(phone_number: phone.full_e164)
                  yield if block_given?
                  render_error(API::RESPONSE_CODES[:internal_server_error], 
                    "Could not create #{resource_name}") unless @current_user.save
              end

              unless @current_user.send_activation_code("sms.auth.#{resource_name}.body")
                render_error(API::RESPONSE_CODES[:internal_server_error], 
                  'Could not create activation code') 
              end
      end

      def validate_code(resource, phone_number, code)
              phone = Phonelib.parse(phone_number, Settings.default_country_code)
              @current_user = resource.find_by(phone_number: phone.full_e164)

              if @current_user.present?
                if @current_user.suspended?
                    render_error(API::RESPONSE_CODES[:unauthorized], 'Account suspended!') 
                  end

                  if @current_user.validate_code(code)
                    yield if block_given?
                    header 'X-Auth-Token', @current_user.token
                  else
                      render_error(API::RESPONSE_CODES[:unauthorized], 'Invalid or expired activation code')
                  end  
              else
                  render_error(API::RESPONSE_CODES[:bad_request], 'Invalid phone number or country code') 
              end
      end
    end
  end
end