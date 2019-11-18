module V1
	module Entities
		module Users

			class Base < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :first_name, documentation: { type: 'String' }
				expose :last_name, documentation: { type: 'String' }
			end

		end
	end
end