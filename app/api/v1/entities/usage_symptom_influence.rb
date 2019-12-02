module V1
	module Entities
		module UsageSymptomInfluences

			class Base < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :user_symptom, with: 'V1::Entities::UserSymptoms::Base', documentation: { 
					type: 'UserSymptoms',}
				expose :influence, documentation: { type: 'Integer' }
			end
		end
	end
end