ActiveAdmin.register SampleAlpha do

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

    includes(:material)

	actions :all

	filter :id
	filter :material

	
	index download_links: [:csv, :zip, :zip_records, :zip_records_combined]

	collection_action :download_samples, method: :post do
		pp collection
		# Do some CSV importing work here...
		redirect_to collection_path, notice: "CSV imported successfully!"
	end

	action_item :view, only: :index do
		#link_to 'View on site', download_samples_admin_samples_path(request.parameters[:q])
	end
	
	member_action :download_csv, method: :get do
		begin
			 # Tell Rack to stream the content
			 headers.delete("Content-Length")
			 # Don't cache anything from this generated endpoint
			 headers["Cache-Control"] = "no-cache"
			 # Tell the browser this is a CSV file
			 headers["Content-Type"] = "text/csv"
			 # Make the file download with a specific filename
			 headers["Content-Disposition"] = "attachment; filename=\"#{resource.file_name}\""
			 # Don't buffer when going through proxy servers
			 headers["X-Accel-Buffering"] = "no"
			 # Set an Enumerator as the body
			 self.response_body = resource.data_type.stream_csv_report_exportable(resource.data, resource.data_type.exportables.first)
			 # Set the status to success
			 response.status = 200
			 #stream_csv
		ensure
			response.stream.close
		end
	end

	index do
		selectable_column
		id_column
        
        column :material
        column :user
		column :device

		column :file_name
		
		actions defaults: true do |instance|
			item "הורד", download_csv_admin_sample_path(instance), class: "member_link"
		end
	end

	show do 
		panel I18n.t('active_admin.details', model: I18n.t('activerecord.models.sample.one')) do
			attributes_table_for sample do
			  	row :id
			  	row :device
				row :material
				row :file_name
			  	row :created_at
				row :updated_at 
				  
				table_for sample.data do
					column :id do |instance|
						link_to instance.id, public_send("admin_#{sample.data_type.model_name.param_key}_path", instance.id)
					end
					column :read_id
					column :file_id
					column :food_label
					column :card
					column :secs_elapsed
					column :ard_state
					column :msec
					column :si
					column :clean_duration
					column :qcm_respond
					column :qcm_1
					column :qcm_2
					column :qcm_3
					column :qcm_4
					column :qcm_5
					column :qcm_6
					column :qcm_7
					column :ht_status
					column :humidiy
					column :temp
					column :fan_type
				end
			end
		end   
	end

	form do |f|
		f.inputs I18n.t('active_admin.details', model: I18n.t('activerecord.models.app_settings.one')) do
			f.input :material
			f.input :user
			f.input :device 
			f.input :files, as: :file, :input_html => { :multiple => true }

			f.inputs do
				f.has_many :data_recods, heading: 'Data Records',
							allow_destroy: true,
							new_record: false do |a|
					a.input :read_id
					a.input :file_id
					a.input :food_label
					a.input :card
					a.input :secs_elapsed
					a.input :ard_state
					a.input :msec
					a.input :si
					a.input :clean_duration
					a.input :qcm_respond
					a.input :qcm_1
					a.input :qcm_2
					a.input :qcm_3
					a.input :qcm_4
					a.input :qcm_5
					a.input :qcm_6
					a.input :qcm_7
					a.input :ht_status
					a.input :humidiy
					a.input :temp
					a.input :fan_type
				end
		end

		end

		f.actions
	end

	controller do
		def create(*args)	
			@uploads = params['sample']['files'].lazy.map{|file|
				begin
					sample = nil
					SampleAlpha.transaction do 
						sample_meta = permitted_params['sample'].to_h
						sample_meta[:file_name] = file.original_filename
						sample = SampleAlpha.create!(sample_meta)
						sample.insert_csv(file.tempfile)
					end
					next file, sample
				rescue => e 
					next file, e
				end
			}
			render 'active_admin/samples/upload', layout: 'active_admin' and return
		end

		def update(*args)
			sample = nil
			SampleAlpha.transaction do 
				id = params['sample']['id']
				Sample.find(id).update_attributes!(permitted_params)
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