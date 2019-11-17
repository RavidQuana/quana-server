module V1
	module Entities
		module Users

			class Base < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :user_name, documentation: { type: 'String' }
				expose :phone_number, documentation: { type: 'String' }
			end

		end
	end
end