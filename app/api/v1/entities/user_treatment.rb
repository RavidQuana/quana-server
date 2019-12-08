module V1
	module Entities
		module UserTreatment

			class Base < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :treatment, with: 'V1::Entities::Enums::Treatment', documentation: { 
					type: 'Treatment'}				
			end


		end
	end
end