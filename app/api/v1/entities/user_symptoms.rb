module V1
	module Entities
		module UserSymptoms

			class Base < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :symptom, with: 'V1::Entities::Enums::Symptom', documentation: { 
					type: 'Symptom'}				
				expose :severity, documentation: { type: 'String' }
			end


		end
	end
end