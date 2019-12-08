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
					{ code: RESPONSE_CODES[:ok], model: V1::Entities::Users::Full },
					{ code: RESPONSE_CODES[:unauthorized], message: 'Invalid or expired user token' }
				] do
					render_success @current_user, V1::Entities::Users::Full
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
					
					namespace :user_symptoms do
						route_param :user_symptom_id do
							#-----[POST]/usages/:usage_id-----
							desc 'delete user symptom'
							params do
								requires :delete_reason, type: String		
							end
							delete '/', http_codes: [
								{ code: API::RESPONSE_CODES[:ok], message: 'ok' },
								{ code: API::RESPONSE_CODES[:bad_request], message: 'Invalid slot id' },
								{ code: API::RESPONSE_CODES[:bad_request], message: 'Slot cannot be cancelled (has pending orders)' },
								{ code: API::RESPONSE_CODES[:internal_server_error], message: 'Failed to cancel slot' }
							] do
								user_symptom = @current_user.user_symptoms.find_by(id: params[:user_symptom_id])
								render_error(API::RESPONSE_CODES[:bad_request], 'Invalid user symptom id') unless user_symptom.present?
								user_symptom.deleted_at = Time.current 
								user_symptom.delete_reason =  params[:delete_reason]
								validate_and_save user_symptom, nil, :save!
							end
						end
					end
			end
		end
	end
end