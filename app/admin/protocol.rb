ActiveAdmin.register Protocol do
	menu url: -> { admin_protocols_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

	actions :all

	filter :id
    filter :name

    form do |f|
		f.inputs do
			f.input :name
			f.input :description, as: :text   
		end
		
		f.actions
    end
    
	controller do
		def permitted_params
			params.permit! 
		end  
	end   
end