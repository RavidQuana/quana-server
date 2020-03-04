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
					usage.save

					if (@filtered_params[:sample].present?)
						begin 
							file = @filtered_params[:sample][:tempfile]
							response = RestClient.put("https://quana-server-staging.herokuapp.com/ml/upload_sample",  {sample: file , id: usage.id, product: usage.product.name, brand: "NA"}, {accept: :json, "x-api-key": "Test"})
							pp "Quana Process server response:"
							pp response.body  
							if response.code != 200 
								usage.error_in_process!
							else 

								responseJSon =  JSON.parse(response.body)
								if  responseJSon["data"]["safe"]
									usage.safe_to_use_status = :safe
								else
									usage.safe_to_use_status = :unsafe
								end
								usage.processed!
							end
						rescue => e
							pp "error in process"
							pp e
							usage.error_in_process!
						end
					else
						if usage.product.has_mold
							usage.safe_to_use_status = :unsafe
						else
							usage.safe_to_use_status = :safe
						end
					end
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


								#-----[GET]/usages/-----
				desc 'get user usages stats'
				get '/stats', http_codes: [
					{ code: RESPONSE_CODES[:ok], message: 'Ok', model: V1::Entities::ProductStat::Base }
				] do
		        	render_success @current_user.stats, 
						V1::Entities::ProductStat::Base			
				end


				desc 'get user usages trend'
				get '/trends', http_codes: [
					{ code: RESPONSE_CODES[:ok], message: 'Ok', model: V1::Entities::Usages::Full }
				] do
					last_usages =  @current_user.usages.order(created_at: :desc).limit(7)
					last_usages = last_usages.sort_by &:created_at
					render_success last_usages , V1::Entities::Usages::Full			
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
						optional :side_effect_ids, type: Array[Integer], desc: "An array of valid side effect ids"

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