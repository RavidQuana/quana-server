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
			end	
		end
	end
end