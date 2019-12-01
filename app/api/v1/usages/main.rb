module V1
	module Usages
		class Main < Grape::API
			include BaseHelpers

			namespace :usages do
				after_validation do
					restrict_access
				end
				#-----[GET]/utils/meta-----
				desc 'Return settings, enums and other static content'
				params do
					use :usage_attributes
				end
				post '/', http_codes: [
					{ code: RESPONSE_CODES[:ok], message: 'Ok', model: V1::Entities::Usages::Full }
				] do
					
					usage = @current_user.usages.new(@filtered_params)
						
					validate_and_save usage, V1::Entities::Usages::Full , :save!   	
				end
			end
		end
	end
end