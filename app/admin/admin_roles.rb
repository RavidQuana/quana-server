ActiveAdmin.register AdminRole do
  	menu url: -> { admin_admin_roles_path(locale: I18n.locale) }, parent: 'system', priority: 2

  	include Admin::Translatable

  	index do
		id_column
	  	column :name do |instance|
			instance.name.titleize
		end
		column :display_name
		column :created_at
		column :updated_at
		actions defaults: true do |instance|
		end 
  	end

  	show do
  		panel I18n.t('active_admin.details', model: I18n.t('activerecord.models.admin_role.one')) do
			attributes_table_for admin_role do
			  	row :id
			  	row :name do |instance|
					instance.name.titleize
				end
			  	row :display_name
			  	row :permissions do |instance|
			  		meta_tags instance.admin_managed_resources, :display_name
			  	end
			  	row :created_at
			  	row :updated_at 
			end
		end   
  	end

  	form do |f|
		f.inputs do 
			f.input :name, input_html: { disabled: !current_admin_user.has_role?(:administrator) && !f.object.new_record? }
			f.input :display_name
			f.input :admin_managed_resources, as: :select2_multiselect, input_html: { data: { select2: { 
				ajax: { url: '/admin/autocomplete/admin_managed_resource' } } } }
		end

		f.actions
  	end

  	controller do
		def permitted_params
	  		params.permit!
		end
  	end
end