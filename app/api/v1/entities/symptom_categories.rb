module V1
	module Entities
		module SymptomCategories

			class Base < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :name, documentation: { type: 'String' }
				expose :symptoms, with: V1::Entities::Symptoms::Base 
			end

		end
	end
end