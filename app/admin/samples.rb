ActiveAdmin.register Sample do
	menu url: -> { admin_samples_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

    includes(:material)

	actions :all

	filter :id
	filter :material

	
	
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

	index download_links: [:csv, :zip, :zip_records, :zip_records_combined] do
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


	controller do
		def new(*args)	
			redirect_to public_send("new_admin_sample_alpha_path")
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