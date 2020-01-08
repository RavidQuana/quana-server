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
			class SideEffect < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :name, documentation: { type: 'String' }
			end

			class Rank < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :name, documentation: { type: 'String' }
				expose :minimal_number_of_scans, documentation: { type: 'String' }
				expose :image_url, as: :image, documentation: { type: 'String' }

			end	
			class Product < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :name, documentation: { type: 'String' }
				expose :pros, documentation: { type: 'String' }
				expose :cons, documentation: { type: 'String' }
				expose :has_mold, documentation: { type: 'Boolean' }

			end	
		end
	end
end