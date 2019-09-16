module V1
	module Entities
		module Utils

			class AppSetting < Grape::Entity
				expose :id, documentation: { type: 'Integer' }
				expose :key, documentation: { type: 'String' }
				expose :value, documentation: { type: 'String' }
			end

			class Price < Grape::Entity
				include ActionView::Helpers

				expose :format, as: :formatted, documentation: { type: 'String' }
				expose :cents, documentation: { type: 'Integer' }
				expose :value, documentation: { type: 'BigDecimal' } do |instance, options|
					instance.to_f
				end
			end

		end
	end
end