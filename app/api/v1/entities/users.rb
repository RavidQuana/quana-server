module V1
	module Entities
		module Users

			class Auth < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :status, documentation: { type: 'String' }
			end
			class Base < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :first_name, documentation: { type: 'String' }
				expose :last_name, documentation: { type: 'String' }
			end

			class Full < Base
				expose :birth_date, documentation: { type: 'DateTime' }
				expose :treatments, with: 'V1::Entities::Enums::Treatment', documentation: { 
					type: 'Treatment', is_array: true }
				expose :user_symptoms, with: 'V1::Entities::UserSymptoms::Base', documentation: { 
						type: 'UserSymptoms', is_array: true }
			end	
		end
	end
end