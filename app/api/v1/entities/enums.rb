module V1
	module Entities
		module Enums
			class Treatment < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :name, documentation: { type: 'String' }
			end	
			class Symptom < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :name, documentation: { type: 'String' }
			end	
		end
	end
end