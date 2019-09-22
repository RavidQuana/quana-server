ActiveAdmin.register SampleAlpha do
    menu :if => proc{ false }   

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
			 # Don't cache anything from this generated endpoint
			 response.headers["Cache-Control"] = "no-cache"
			 # Tell the browser this is a CSV file
			 response.headers["Content-Type"] = "text/csv"
			 # Make the file download with a specific filename
			 response.headers["Content-Disposition"] = "attachment; filename=\"#{resource.file_name}\""
			 # Don't buffer when going through proxy servers
			 response.headers["X-Accel-Buffering"] = "no"
			 # Set an Enumerator as the body
			 resource.data_type.stream_csv_report(resource.data).lazy.each{|row|
				response.stream.write(row)
			 }
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
			item "הורד", public_send("download_csv_admin_#{instance.class.model_name.param_key}_path", instance.id), class: "member_link"
		end
	end

	show do 
		panel I18n.t('active_admin.details', model: I18n.t('activerecord.models.sample_alpha.one')) do
			attributes_table_for sample_alpha do
			  	row :id
			  	row :device
				row :material
				row :file_name
			  	row :created_at
				row :updated_at 
				  
				table_for sample_alpha.data_records do
					column :id do |instance|
						link_to instance.id, public_send("admin_#{sample_alpha.data_type.model_name.param_key}_path", instance.id)
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

                if sample_alpha.data_records.count > 0 
                    min_max = sample_alpha.data_records.map{|data| [
                        data.qcm_1,
                        data.qcm_2,
                        data.qcm_3,
                        data.qcm_4,
                        data.qcm_5,
                        data.qcm_6,
                        data.qcm_7]}.flatten.minmax { |a, b| a <=> b }
    
                    space = (min_max[1] - min_max[0]) * 0.1
    
                    div line_chart [
                        {name: "qcm_1", data: sample_alpha.data_records.map { |data_record| [data_record.secs_elapsed, data_record.qcm_1] }},
                        {name: "qcm_2", data: sample_alpha.data_records.map { |data_record| [data_record.secs_elapsed, data_record.qcm_2] }},
                        {name: "qcm_3", data: sample_alpha.data_records.map { |data_record| [data_record.secs_elapsed, data_record.qcm_3] }},
                        {name: "qcm_4", data: sample_alpha.data_records.map { |data_record| [data_record.secs_elapsed, data_record.qcm_4] }},
                        {name: "qcm_5", data: sample_alpha.data_records.map { |data_record| [data_record.secs_elapsed, data_record.qcm_5] }},
                        {name: "qcm_6", data: sample_alpha.data_records.map { |data_record| [data_record.secs_elapsed, data_record.qcm_6] }},
                        {name: "qcm_7", data: sample_alpha.data_records.map { |data_record| [data_record.secs_elapsed, data_record.qcm_7] }}
                    ], min: min_max[0]-space, max: min_max[1]+space
    
                    div line_chart [
                        {name: "humidity", data: sample_alpha.data_records.map { |data_record| [data_record.secs_elapsed, data_record.humidiy] }},
                        {name: "temp", data: sample_alpha.data_records.map { |data_record| [data_record.secs_elapsed, data_record.temp] }},
                    ]
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
				f.has_many :data_records, heading: 'Data Records',
							allow_destroy: true,
							new_record: true do |a|
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
            if params['sample_alpha']['files'].present?
                @uploads = params['sample_alpha']['files'].lazy.map{|file|
                    begin
                        sample = nil
                        SampleAlpha.transaction do 
                            sample_meta = permitted_params['sample_alpha'].to_h
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
            else    
                super
            end
		end

		def update(*args)
			sample = nil
			SampleAlpha.transaction do 
				id = params['id']
				SampleAlpha.find(id).update!(permitted_params['sample_alpha'])
				params['sample_alpha']['files'].each{|file|
					#sample = SampleAlpha.create!(permitted_params['sample'])
					#sample.insert_csv(file.tempfile)
				} if params['sample_alpha']['files'].present?
				redirect_to collection_url(locale: I18n.locale) and return
			end

			flash.now[:error] = sample.errors.full_messages.join(', ')
			render :new
		end

		def permitted_params
            #params.permit(sample_alpha: [:material_id, :user_id, :device, :data_records_attributes])
            params.permit!
		end  

		def scoped_collection
			super.includes :material
		end      
	end   
end