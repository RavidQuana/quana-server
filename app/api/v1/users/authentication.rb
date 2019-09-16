module V1
    module Users
        class Authentication < Grape::API
            include UserHelpers

            namespace :auth do
                #-----[POST]/auth/validate_code-----
                # desc 'Validate activation code and return an access token', security: -> {[]},
                #   consumes: ['multipart/form-data', 'application/json'],
                #   entity: User::Entity
                # params do
                #   requires :code, type: String, desc: 'A Predictix user code to validate'
                # end
                # post :validate_code, http_codes: [
                #   { code: RESPONSE_CODES[:ok], model: User::Entity },
                #   { code: RESPONSE_CODES[:unauthorized], message: 'Invalid or expired activation code' },
                #   { code: RESPONSE_CODES[:unauthorized], message: 'Account suspended!' }
                # ] do
                #   @current_user = User.find_by(code: params[:code])

                #   render_error(RESPONSE_CODES[:unauthorized], 'Invalid or expired activation code') unless @current_user.present?
                #   render_error(RESPONSE_CODES[:unauthorized], 'Account suspended!') if @current_user.suspended?

                #   @current_user.first_sign_in_at ||= Time.zone.now
                #   @current_user.active!

                #   header 'X-Auth-Token', @current_user.token
                #   render_success @current_user, User::Entity
                # end 
            end
        end
    end
end