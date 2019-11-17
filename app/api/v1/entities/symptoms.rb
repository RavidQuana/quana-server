module V1
	module Entities
		module Symptoms

			class Base < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :name, documentation: { type: 'String' }
			end

		end
	end
end