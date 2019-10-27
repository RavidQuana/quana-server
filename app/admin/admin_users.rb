ActiveAdmin.register AdminUser do
	menu url: -> { admin_admin_users_path(locale: I18n.locale) }, parent: 'system', priority: 1

	actions :all, except: :show 

	include Admin::Translatable
	include Admin::Exportable

	filter :id
	filter :first_name
	filter :last_name
	filter :email
	filter :last_sign_in_at, as: :date_time_range, datepicker_options: { timepicker: true, format: 'Y-m-d H:i' }
	filter :created_at, as: :date_time_range, datepicker_options: { timepicker: true, format: 'Y-m-d H:i' } 

	index do
		selectable_column
		id_column
		column :name
		column :email
		column :thumbnail do |instance|
			image_thumb instance.thumbnail_url 
		end 
		column :admin_role do |instance|
			meta_tag instance, :role_name, { formatter: ->(v) { v.titleize } }
		end
		column :last_sign_in_at
		column :current_sign_in_at
		column :sign_in_count
		column :created_at
		actions defaults: true do |instance|
		end    
	end

	form do |f|
		f.inputs I18n.t('active_admin.details', model: I18n.t('activerecord.models.admin_user.one')) do
			f.input :first_name
			f.input :last_name
			f.input :email
			#f.input :thumbnail, as: :s3_file
			f.input :password
			f.input :password_confirmation
			f.input :admin_role, as: :select2, collection: f.object.admin_role.try(:select2_item) || [], 
				input_html: { data: { select2: { ajax: { url: '/admin/autocomplete/admin_role' } } } } 
		end

		f.actions
	end

	controller do
		def permitted_params
			params.permit! 
		end

		def update
			@account = AdminUser.find(params[:id])
			account_params = permitted_params[:admin_user]

			if account_params[:password].blank? && account_params[:password_confirmation].blank?
				@account.update_without_password(account_params)
			else
				@account.update_attributes(account_params)
			end

			if @account.errors.blank?
				respond_to do |format|
					format.html { redirect_to admin_admin_users_path, 
						notice: I18n.t('active_admin.batch_actions.succesfully_updated.one', 
						model: I18n.t('activerecord.models.admin_account.one')) }
				end
			else
				flash.now[:error] = @account.errors.values.uniq.reject { |e| e.blank? }.join(', ')

				respond_to do |format|
					format.html { render :edit }
				end
			end
		end   
	end
end