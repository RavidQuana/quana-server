ActiveAdmin.register AppSettings do
	menu url: -> { admin_app_settings_path(locale: I18n.locale) }, parent: 'system', priority: 3

	include Admin::Translatable

	actions :all, except: [:show, :destroy]
	config.batch_actions = false

	filter :id
	filter :key
	filter :value
	filter :is_client_accessible, as: :select2_boolean
	filter :created_at, as: :date_time_range, datepicker_options: { timepicker: true, format: 'Y-m-d H:i' }
	filter :updated_at, as: :date_time_range, datepicker_options: { timepicker: true, format: 'Y-m-d H:i' }

	index do 
		id_column
		column :key do |instance|
			meta_tag instance, :key
		end
		column :value
		column :data_type do |instance|
			enum_tag instance, :data_type
		end
		column :description
		column :is_client_accessible
		column :created_at
		column :updated_at
		actions defaults: true do |instance|
		end  
	end

	form do |f|
		f.inputs I18n.t('active_admin.details', model: I18n.t('activerecord.models.app_settings.one')) do
			f.input :key, input_html: { disabled: !current_admin_user.has_role?(:administrator) && !f.object.new_record? }
			f.input :value
			f.input :data_type, as: :select2, collection: options_for_select(enum_value_select(AppSettings, 
				:data_type), f.object.try(:data_type))
			f.input :description 
			f.input :is_client_accessible       
		end

		f.actions
	end

	controller do
		def permitted_params
			params.permit! 
		end
	end   
end