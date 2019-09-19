ActiveAdmin.register Material do
	menu url: -> { admin_materials_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

	actions :all

	filter :id
    filter :name

	index do
		selectable_column
		id_column
        column :name
	end

	controller do
		def permitted_params
			params.permit! 
		end  

	end   
end