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
				expose :gender, documentation: { type: 'Gender' }
				expose :status, documentation: { type: 'String' }
				expose :birth_date, documentation: { type: 'DateTime' }
				expose :cannabis_use_years, documentation: { type: 'Integer' }
				expose :cannabis_use_monthes, documentation: { type: 'Integer' }
				expose :cannabis_use_frequency, documentation: { type: 'String' }
				expose :blood_sugar_medications, documentation: { type: 'Boolean' }

				expose :treatments, with: 'V1::Entities::Enums::Treatment', documentation: { 
					type: 'Treatment', is_array: true }
				expose :user_symptoms, with: 'V1::Entities::UserSymptoms::Base', documentation: { 
						type: 'UserSymptoms', is_array: true }

				expose :last_usages, with: 'V1::Entities::Usages::Full', documentation: { 
						type: 'Usage', is_array: true }
			end	
		end
	end
end