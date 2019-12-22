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

				expose :user_treatments, with: 'V1::Entities::UserTreatment::Base', documentation: { 
					type: 'UserTreatment', is_array: true }
				expose :user_symptoms, with: 'V1::Entities::UserSymptoms::Base', documentation: { 
						type: 'UserSymptoms', is_array: true }

				expose :number_of_reviews, documentation: { type: 'Integer' }

				expose :last_usages, with: 'V1::Entities::Usages::Full', documentation: { 
						type: 'Usage', is_array: true }
				expose :current_rank, with: 'V1::Entities::Enums::Rank', documentation: { 
							type: 'Rank'}	
				expose :next_rank, with: 'V1::Entities::Enums::Rank', documentation: { 
							type: 'Rank'}	
			end	
		end
	end
end