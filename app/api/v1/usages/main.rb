module V1
	module Usages
		class Main < Grape::API
			include BaseHelpers

			namespace :usages do
				#-----[GET]/utils/meta-----
				desc 'Return settings, enums and other static content', security: -> {[]}
				get :meta, http_codes: [
					{ code: RESPONSE_CODES[:ok], message: 'Ok' }
				] do
					meta = {
						settings: AppSettings.client_accessible.map { |setting| V1::Entities::Utils::AppSetting.represent(setting) },
						symptom_categories: SymptomCategory.all.map {|category| V1::Entities::SymptomCategories::Base.represent(category) },
						treatments: Treatment.all.map {|treatment| V1::Entities::Treatments::Base.represent(treatment) }

					}

					render_success meta
				end
			end
		end
	end
end