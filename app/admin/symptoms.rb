ActiveAdmin.register Symptom do
	# menu url: -> { admin_admin_users_path(locale: I18n.locale) }, parent: 'system', priority: 1

	actions :all

	include Admin::Translatable
	include Admin::Exportable


	index do
		selectable_column
		id_column
		column :name
		column :symptom_category
		actions defaults: true do |instance|
		end    
	end

	form do |f|
		f.inputs I18n.t('active_admin.details', model: I18n.t('activerecord.models.admin_user.one')) do
			f.input :name
			f.input :symptom_category
		end
		f.actions
	end

	show do 
		panel I18n.t('user.details', model: I18n.t('activerecord.models.sample_alpha.one')) do
			attributes_table_for symptom do
				row :id
				row :name
				row :symptom_category

			end
		end
	end

	controller do
		def permitted_params
			params.permit! 
		end
	end
end