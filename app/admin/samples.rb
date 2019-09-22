ActiveAdmin.register Sample do
	menu url: -> { admin_samples_path(locale: I18n.locale) } 

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

		def show()
			redirect_to public_send("admin_#{resource.model_name.param_key}_path", resource)
		end

		def edit()
			redirect_to public_send("edit_admin_#{resource.model_name.param_key}_path", resource)
		end

		def permitted_params
			params.permit(sample: [:material_id, :user_id, :device])
		end  

		def scoped_collection
			super.includes :material
		end      
	end   
end