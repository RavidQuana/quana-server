ActiveAdmin.register Sampler do
	menu url: -> { admin_samplers_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

	actions :all

	filter :id
    filter :name

    form do |f|
		f.inputs do
			f.input :name
			f.input :sampler_type, as: :select2
		end
		
		f.actions
	end

	controller do
		def permitted_params
			params.permit! 
		end  
	end   
end