module V1
	module Users
		class Me < Grape::API
			include BaseHelpers
			include UserHelpers

			namespace :me do
				after_validation do
					restrict_access
				end

				#-----[GET]/users/me-----
				desc "Return the current user's profile",
				    entity: V1::Entities::Users::Full
				get '/', http_codes: [
					{ code: RESPONSE_CODES[:ok], model: V1::Entities::Users::Base },
					{ code: RESPONSE_CODES[:unauthorized], message: 'Invalid or expired user token' }
				] do
					render_success @current_user, V1::Entities::Users::Base
				end

					#-----[POST]/users/me-----
			        desc "Update the current user's profile",
			        	consumes: ['multipart/form-data', 'application/json'],
			            entity: V1::Entities::Users::Base       
			        params do
			        	use :user_attributes
			        end
			        post '/', http_codes: [
			        	{ code: API::RESPONSE_CODES[:ok], message: 'ok', model: V1::Entities::Users::Base },
			        	{ code: API::RESPONSE_CODES[:unauthorized], message: 'Invalid or expired user token' },
			        	{ code: API::RESPONSE_CODES[:bad_request], message: 'Validation failed' },
			        	{ code: API::RESPONSE_CODES[:internal_server_error], message: 'Failed to update user profile' }
					] do
		        		@current_user.assign_attributes(
							@filtered_params.except(:user_symptoms).merge({
	        					user_symptoms_attributes: @filtered_params[:user_symptoms] || []
	        				})
						)
						
						@current_user.assign_attributes(status: :active) if @current_user.pending_details? && @current_user.first_name.present?
						validate_and_save @current_user, V1::Entities::Users::Full , :save!   	
			        end

				#-----[POST]/users/me-----
				# desc "Update the current user's profile",
				# 	consumes: ['multipart/form-data', 'application/json'],
				#     entity: User::Entity
				# params do
				# 	use :user_attributes
				# 	use :device_attributes
				# end
				# post '/', http_codes: [
				# 	{ code: RESPONSE_CODES[:ok], model: User::Entity },
				# 	{ code: RESPONSE_CODES[:unauthorized], message: 'Invalid or expired user token' },
				# 	{ code: RESPONSE_CODES[:internal_server_error], message: 'Could not update user profile' }
				# ] do
				# 	@current_user.assign_attributes({  }.reject { |k, v| !params.has_key?(k) })
				# 	render_error(RESPONSE_CODES[:internal_server_error], 'Could not update user profile') unless @current_user.save
				# 	attach_device

				# 	@current_user.reload

				# 	render_success @current_user, User::Entity
				# end
			end
		end
	end
end