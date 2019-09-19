ActiveAdmin.register Sample do
	menu url: -> { admin_samples_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

    includes(:material)

	actions :all

	filter :id
    filter :material

	index do
		selectable_column
		id_column
        
        column :type
        column :material
        column :user
        column :device
	end

	form do |f|
		f.inputs I18n.t('active_admin.details', model: I18n.t('activerecord.models.app_settings.one')) do
			f.input :material
			f.input :user
			f.input :device 
			f.input :files, as: :file, :input_html => { :multiple => true }
		end

		f.actions
	end

	controller do
		def create(*args)
			sample = nil
			SampleAlpha.transaction do 
				params['sample']['files'].each{|file|
					sample = SampleAlpha.create!(permitted_params['sample'])
					sample.insert_csv(file.tempfile)
				}
				redirect_to collection_url(locale: I18n.locale) and return
			end

			flash.now[:error] = sample.errors.full_messages.join(', ')
			render :new
		end

		def permitted_params
			params.permit(sample: [:material_id, :user_id, :device])
		end  

		def scoped_collection
			super.includes :material
		end      
	end   
end