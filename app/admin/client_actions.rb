ActiveAdmin.register ClientAction do
	menu url: -> { admin_client_actions_path(locale: I18n.locale) }, parent: 'notifications', priority: 3

	include Admin::Translatable

	actions :all, except: :show

	filter :name
	filter :required_linkable_type, as: :select2_multiselect, collection: -> { polymorphic_type_select(Notification, :linkable) }
	filter :created_at, as: :date_time_range, datepicker_options: { timepicker: true, format: 'Y-m-d H:i' }
	filter :updated_at, as: :date_time_range, datepicker_options: { timepicker: true, format: 'Y-m-d H:i' }

	index download_links: false do
		selectable_column 
		id_column
		column :name do |instance|
			meta_tag instance, :name
		end
		column :required_linkable_type
		column :created_at
		column :updated_at
		actions defaults: true do |instance|
		end  
	end

	form do |f|
		f.inputs do
			f.input :name
			f.input :required_linkable_type, as: :select2, collection: polymorphic_type_select(Notification, :linkable)
		end
		
		f.actions
	end   

	controller do
		def permitted_params
			params.permit! 
		end
	end   
end