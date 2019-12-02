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

				#-----[GET]/usages/-----
				desc 'get user usages'
				get '/', http_codes: [
					{ code: RESPONSE_CODES[:ok], message: 'Ok', model: V1::Entities::Usages::Full }
				] do
		        	render_success @current_user.usages.order(created_at: :desc), 
						V1::Entities::Usages::Full			
				end

				route_param :usage_id do
					after_validation do
					  get_usage
					end

					#-----[POST]/usages/:usage_id-----
					desc 'create a new user usage'
					params do
						requires :usage_symptoms_influence, type: Array[JSON] do
							use :usage_symptom_influence_attributes
						  end
					end
					post '/', http_codes: [
						{ code: RESPONSE_CODES[:ok], message: 'Ok', model: V1::Entities::Usages::Full }
					] do
					
					
						@usage.assign_attributes(
							@filtered_params.except(:usage_symptoms_influence).merge({
	        					usage_symptom_influences_attributes: @filtered_params[:usage_symptoms_influence] || []
	        				})
						)						
						validate_and_save @usage, V1::Entities::Usages::Full , :save!   
					end
				end
			end
		end
	end
end