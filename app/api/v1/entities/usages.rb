module V1
	module Entities
		module Usages

			class Base < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :created_at, documentation: { type: 'DateTime' }

				
			end

			class Full < Base
				expose :product, with: 'V1::Entities::Enums::Product', documentation: { 
					type: 'Product'}		
				expose :usage_symptom_influences, with: 'V1::Entities::UsageSymptomInfluences::Base', documentation: { 
						type: 'UsageSymptomInfluence'}
				expose :side_effects, with: 'V1::Entities::Enums::SideEffect', documentation: { 
							type: 'SideEffect', is_array: true }
				expose :safe_to_use_status, documentation: { type: 'String' }
			end	
		end
	end
end