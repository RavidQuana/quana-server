ActiveAdmin.register Notification do
	menu url: -> { admin_notifications_path(locale: I18n.locale) }, label: I18n.t('active_admin.menus.main'), 
		parent: 'notifications', priority: 1

	include Admin::Translatable

	actions :all, only: [:index]

	filter :sender_type, as: :select2, collection: -> { polymorphic_type_select(Notification, :sender) }
	filter :sender_id, as: :select2_multiselect, input_html: { data: { select2: { ajax: { 
		url: '/admin/autocomplete/polymorphic' } }, dependencies: [{ source: '#q_sender_type', 
		key: 'type', required: true }] } }
	filter :receiver_type, as: :select2, collection: -> { polymorphic_type_select(Notification, :receiver) }
	filter :receiver_id, as: :select2_multiselect, input_html: { data: { select2: { ajax: { 
		url: '/admin/autocomplete/polymorphic' } }, dependencies: [{ source: '#q_receiver_type', 
		key: 'type', required: true }] } }
	filter :notification_type_id, as: :select2_multiselect, input_html: { data: { select2: { ajax: { 
		url: '/admin/utils/autocomplete/notification_type' } } } }
	filter :linkable_type, as: :select2, collection: -> { polymorphic_type_select(Notification, :linkable) }
	filter :linkable_id, as: :select2_multiselect, input_html: { data: { select2: { ajax: { 
		url: '/admin/autocomplete/polymorphic' } }, dependencies: [{ source: '#q_linkable_type', 
		key: 'type', required: true }] } }
	filter :delivery_status, as: :select2_multiselect, collection: -> { enum_value_select(Notification, :delivery_status) }
	filter :created_at, as: :date_time_range, datepicker_options: { timepicker: true, format: 'Y-m-d H:i' }

	index download_links: false do
		selectable_column    
		id_column
		column :sender
		column :receiver
		column :notification_type
		column :body
		column :linkable
		column :delivery_status do |instance|
			enum_tag instance, :delivery_status
		end
		column :created_at
	end

	controller do
		def permitted_params
			params.permit! 
		end

		def scoped_collection
			super.includes :sender, :receiver, :notification_type, :linkable
		end    				
	end   
end