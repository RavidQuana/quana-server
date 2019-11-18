module V1
    module Users
        class Authentication < Grape::API
            namespace :auth do
                #-----[POST]/users/auth/get_code-----
                desc 'Request a new activation code (sent via sms)', security: -> {[]},
                    consumes: ['multipart/form-data', 'application/json']
                params do
                    requires :phone_number, type: String, desc: "The users's phone number"
                end
                post :get_code, http_codes: [
                    { code: API::RESPONSE_CODES[:ok], message: 'ok' },
                    { code: API::RESPONSE_CODES[:internal_server_error], message: 'Could not create user' },
                    { code: API::RESPONSE_CODES[:internal_server_error], message: 'Could not create activation code' }
                ] do
                    get_code(User, params[:phone_number])
                    render_success nil
                end 

                #-----[POST]/users/auth/validate_code-----
                desc 'Validate activation code and return an access token', security: -> {[]},
                    consumes: ['multipart/form-data', 'application/json'],
                    entity: V1::Entities::Users::Base
                params do
                    requires :phone_number, type: String, desc: "The users's phone number"
                    requires :code, type: String, desc: 'A 4-digit code to validate'
                end
                post :validate_code, http_codes: [
                    { code: API::RESPONSE_CODES[:ok], message: 'ok', model: V1::Entities::Users::Base },
                    { code: API::RESPONSE_CODES[:bad_request], message: 'Invalid phone number or country code' },
                    { code: API::RESPONSE_CODES[:unauthorized], message: 'Account suspended!' },
                    { code: API::RESPONSE_CODES[:unauthorized], message: 'Invalid or expired activation code' },
                    { code: API::RESPONSE_CODES[:internal_server_error], message: 'Could not update user data' }
                ] do
                    validate_code(User, params[:phone_number], params[:code]) do
                        if @current_user.pending_verification?
                            begin
                                @current_user.active!
                            rescue => e
                                render_error(API::RESPONSE_CODES[:internal_server_error], "Could not update user data")
                            end
                        end

                        render_success @current_user, V1::Entities::Users::Base
                    end
                end  
            end
        end
    end
end