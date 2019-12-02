ActiveAdmin.register Product do
	menu url: -> { admin_products_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

	actions :all

	filter :id
	filter :name
	filter :brand

    form do |f|
		f.inputs do
			f.input :name 
			f.input :pros 
			f.input :cons 
			f.input :has_mold 

			f.input :brand, as: :select2
		end
		
		f.actions
	end

	controller do
		def permitted_params
			params.permit! 
		end  
	end   
end