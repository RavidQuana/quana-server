ActiveAdmin.register NotificationType do
	menu url: -> { admin_notification_types_path(locale: I18n.locale) }, parent: 'notifications', priority: 2

	include Admin::Translatable

	actions :all, except: :show

	filter :name
	filter :client_action_id, as: :select2_multiselect, input_html: { data: { select2: 
		{ ajax: { url: '/admin/autocomplete/client_action' } } } }
	filter :send_push, as: :select2_boolean
	filter :send_sms, as: :select2_boolean
	filter :created_at, as: :date_time_range, datepicker_options: { timepicker: true, format: 'Y-m-d H:i' }
	filter :updated_at, as: :date_time_range, datepicker_options: { timepicker: true, format: 'Y-m-d H:i' }

	index download_links: false do
		selectable_column
		id_column
		column :name
		column :body_pattern
		column :client_action do |instance|
			meta_tag instance, :client_action_name, { link_type: :admin_resource }
		end
		column :send_push do |instance|
			boolean_tag instance, :send_push
		end
		column :send_sms do |instance|
			boolean_tag instance, :send_sms
		end
		column :created_at
		actions defaults: true do |instance|
		end
	end

	form do |f|
		f.inputs do
			f.input :name, input_html: { disabled: !current_admin_user.has_role?(:administrator) && !f.object.new_record? }
			f.input :body_pattern, as: :multilingual_text
			f.input :client_action, as: :select2, collection: f.object.client_action.try(:select2_item) || [], 
				input_html: { data: { select2: { ajax: { url: '/admin/autocomplete/client_action' } } } } 
			f.input :send_push
			f.input :send_sms
		end

		f.actions
	end

	controller do
		def permitted_params
			params.permit!
		end

    	def scoped_collection
      		super.includes :client_action
    	end 
	end
end