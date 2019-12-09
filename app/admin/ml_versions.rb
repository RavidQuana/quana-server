ActiveAdmin.register MLVersion do
	menu url: -> { admin_ml_versions_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Scopable 

	actions :all

	filter :id
    filter :name
    
    #need to always show batch actions
    config.batch_actions = true
    config.scoped_collection_actions_if = -> { true }
    
    scoped_collection_action :update_versions, method: :post, class: 'download-trigger member_link_scope',  title: "עדכן" do
		MlController.update_versions()
		redirect_to collection_path, notice: "Versions updated."
    end

    form do |f|
		f.inputs do
			f.input :name 
			f.input :status
		end
		
		f.actions
	end

	controller do
		def permitted_params
			params.permit! 
		end  
	end   
end