module V1
	module Entities
		module Treatments

			class Base < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :name, documentation: { type: 'String' }
			end

		end
	end
end