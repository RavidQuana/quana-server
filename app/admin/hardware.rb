ActiveAdmin.register Hardware do
	menu url: -> { admin_hardwares_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

	actions :all

	filter :id
    filter :name

    form do |f|
		f.inputs do
			f.input :scanner, as: :select2
			f.input :version   
		end
		
		f.actions
	end

	controller do
		def permitted_params
			params.permit! 
		end  
	end   
end