module V1
	module Entities
		module Usages

			class Base < Grape::Entity
				expose :id, documentation: { type: 'Integer' }

			end

			class Full < Base
				expose :product_id, documentation: { type: 'Integer' }
				
			end	
		end
	end
end