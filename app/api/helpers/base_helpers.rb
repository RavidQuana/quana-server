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
    end
  end
end