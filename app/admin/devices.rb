ActiveAdmin.register Device, scopes: { device_type: :type } do
	menu url: -> { admin_devices_path(locale: I18n.locale) }, parent: 'notifications', priority: 4

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

	actions :all, except: [:new, :show]

	filter :id
	filter :owner_type, as: :select2, collection: -> { polymorphic_type_select(Device, :owner) }
	filter :owner_id, as: :select2_multiselect, input_html: { data: { select2: { ajax: { 
		url: '/admin/autocomplete/polymorphic' } }, dependencies: [{ source: '#q_owner_type', 
		key: 'type', required: true }] } }
	filter :device_type
	filter :device_token
	filter :os_type, as: :select2_multiselect, collection: -> { enum_value_select(Device, :os_type) }
	filter :os_version
	filter :app_version
	filter :failed_attempts
	filter :is_sandbox, as: :select2_boolean
	filter :created_at, as: :date_time_range, datepicker_options: { timepicker: true, format: 'Y-m-d H:i' }
	filter :updated_at, as: :date_time_range, datepicker_options: { timepicker: true, format: 'Y-m-d H:i' }

	index do
		selectable_column
		id_column
		column :owner 
		column :device_type
		column :device_token
		column :os_type do |instance|
			enum_tag instance, :os_type
		end 
		column :os_version
		column :app_version
		column :failed_attempts
		column :is_sandbox do |instance|
			boolean_tag instance, :is_sandbox
		end
		column :created_at
		actions defaults: true do |instance| 
		end       
	end

	form do |f|
		f.inputs do
			f.input :owner_type, as: :select2, collection: options_for_select(polymorphic_type_select(Device, :owner), 
				f.object.try(:owner_type))
			f.input :owner_id, as: :select2, collection: f.object.owner.try(:select2_item) || [], 
				input_html: { data: { select2: { ajax: { url: '/admin/autocomplete/polymorphic' } },
				dependencies: [{ source: '#device_owner_type', key: 'type', required: true }] } }
			f.input :device_type
			f.input :device_token
			f.input :os_type, as: :select2, collection: options_for_select(enum_value_select(Device, :os_type), 
				f.object.try(:os_type))
			f.input :os_version
			f.input :app_version
			f.input :is_sandbox      
		end
		
		f.actions
	end

	controller do
		def permitted_params
			params.permit! 
		end  

		def scoped_collection
			super.includes :owner
		end      
	end   
end