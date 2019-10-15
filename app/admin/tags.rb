ActiveAdmin.register Tag do
	menu url: -> { admin_tags_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

	actions :all

	filter :id
    filter :name


	controller do
		def permitted_params
			params.permit! 
		end  
	end   
end