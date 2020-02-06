module V1
	module Entities
		module ProductStat
			class Base < Grape::Entity
				expose :product, with: 'V1::Entities::Enums::Product', documentation: { 
					type: 'Product'}
				expose :usage_count, documentation: { type: 'Integer' }
				expose :side_effects, with: 'V1::Entities::Enums::SideEffect', documentation: { 
					type: 'SideEffect', is_array: true }		
			end
		end
	end
end