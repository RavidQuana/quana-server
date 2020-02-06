module V1
	module Entities
		module ProductStat
			class Base < Grape::Entity
				expose :product, with: 'V1::Entities::Enums::Product', documentation: { 
					type: 'Product'}
				expose :usage_count, documentation: { type: 'Integer' }
				expose :symptoms, with: 'V1::Entities::ProductStatSymtpomAverage::Base', documentation: { 
					type: 'ProductStatSymtpomAverage', is_array: true }	
				expose :side_effects, with: 'V1::Entities::Enums::SideEffect', documentation: { 
					type: 'SideEffect', is_array: true }		
			end
		end

		module ProductStatSymtpomAverage
			class Base < Grape::Entity
				expose :symptom, with: 'V1::Entities::Enums::Symptom', documentation: { 
					type: 'Symptom'}
				expose :average, documentation: { type: 'Integer' }
			end
		end
	end
end