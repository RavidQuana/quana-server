module V1
	module Usages
		class Main < Grape::API
			include BaseHelpers
			include UsageHelpers

			namespace :usages do
				after_validation do
					restrict_access
				end
				#-----[POST]/usages/-----
				desc 'create a new user usage'
				params do
					use :usage_attributes
				end
				post '/', http_codes: [
					{ code: RESPONSE_CODES[:ok], message: 'Ok', model: V1::Entities::Usages::Full }
				] do
					
					usage = @current_user.usages.new(@filtered_params)
						
					validate_and_save usage, V1::Entities::Usages::Full , :save!   	
				end

				route_param :usage_id do
					after_validation do
					  get_usage
					end

					#-----[POST]/usages/:usage_id-----
					desc 'create a new user usage'
					params do
						requires :usage_symptoms_influance, type: Array[JSON] do
							use :usage_symptom_influance_attributes
						  end
					end
					post '/', http_codes: [
						{ code: RESPONSE_CODES[:ok], message: 'Ok', model: V1::Entities::Usages::Full }
					] do
					
					
						@usage.assign_attributes(
							@filtered_params.except(:usage_symptoms_influance).merge({
	        					usage_symptom_influences_attributes: @filtered_params[:usage_symptoms_influance] || []
	        				})
						)						
						validate_and_save @usage, V1::Entities::Usages::Full , :save!   
					end
				end
			end
		end
	end
end