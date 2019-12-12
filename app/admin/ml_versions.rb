ActiveAdmin.register MLVersion do
	menu url: -> { admin_ml_versions_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Scopable 

	actions :all, except: [:edit]

	filter :id
    filter :name
    
    #need to always show batch actions
    config.batch_actions = true
    config.scoped_collection_actions_if = -> { true }
    
    scoped_collection_action :update_versions, method: :post, class: 'download-trigger member_link_scope',  title: "עדכן" do
		MlController.update_versions()
		redirect_to collection_path, notice: "Versions updated."
	end

	member_action :activate, method: :get do
		MLVersion.all.update_all(status: :ready)
		resource.active!
		redirect_to collection_path, notice: "Activated."
  	end
	
	index do
		selectable_column
		id_column
		column :name 
		column :status
		column :query
		#column :query_humanize
		column :created_at

		actions defaults: true do |instance|
			item "Activate", public_send("activate_admin_ml_version_path", instance.id), class: "member_link"
		end     
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