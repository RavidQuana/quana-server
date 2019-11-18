ActiveAdmin.register User do
	# menu url: -> { admin_admin_users_path(locale: I18n.locale) }, parent: 'system', priority: 1

	actions :all

	include Admin::Translatable
	include Admin::Exportable

	filter :id
	filter :user_name
	filter :phone_number
	filter :email

	index do
		selectable_column
		id_column
		column :phone_number
		actions defaults: true do |instance|
		end    
	end

	form do |f|
		f.inputs I18n.t('active_admin.details', model: I18n.t('activerecord.models.admin_user.one')) do
			f.input :user_name
			f.input :phone_number
			f.input :birth_date , as: :date_time_picker, datepicker_options: { timepicker: false, format: 'Y-m-d H:i' }
			f.input :requires_local_auth
			f.input :status
		end
		f.actions
	end

	show do 
		panel I18n.t('user.details', model: I18n.t('activerecord.models.sample_alpha.one')) do
			attributes_table_for user do
				row :id
				row :phone_number
				row :birth_date
				row :token
				row :status
				row :requires_local_auth
			end
		end
	end

	controller do
		def permitted_params
			params.permit! 
		end
	end
end