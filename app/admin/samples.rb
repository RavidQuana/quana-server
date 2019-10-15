ActiveAdmin.register Sample do
	menu url: -> { admin_samples_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

	actions :all

	filter :id
    filter :device
    filter :file_name

    #need to always show batch actions
    config.batch_actions = true
    config.scoped_collection_actions_if = -> { true }
    scoped_collection_action :download_csv_scope, method: :post, class: 'download-trigger member_link_scope',  title: "הורדה מופרד" do

        samples = scoped_collection_records
        if params[:collection_selection].present?
            samples = Sample.where(id: params[:collection_selection][0].values)
        end
        
        begin
             # Set a reasonable content type
             response.headers['Content-Type'] = 'application/zip'
             # Make sure nginx buffering is suppressed - see https://github.com/WeTransfer/zip_tricks/issues/48
             response.headers['X-Accel-Buffering'] = 'no'
             # Create a wrapper for the write call that quacks like something you
             response.headers["Content-Disposition"] = "attachment; filename=\"samples.zip\""
            w = ZipTricks::BlockWrite.new { |chunk| response.stream.write(chunk) }
              ZipTricks::Streamer.open(w) { |zip| 
                samples.pluck_in_batches(:id, :type, :file_name, batch_size: 500) {|batch| 
                batch.each{|id, type, file_name|
                  sample_type = type.constantize
                  zip.write_deflated_file(file_name) { |sink|
                    sample_type.data_type.stream_csv_report(sample_type.data_type.where(sample_id: id)).lazy.each{|row|
                      sink.write(row)
                    }
                  }
                }
              }
            }
       ensure
           response.stream.close
       end
    end

    scoped_collection_action :download_csv_combined_scope, method: :post, class: 'download-trigger member_link_scope',  title: "הורדה מאוחד" do
        samples = scoped_collection_records
        if params[:collection_selection].present?
            pp params[:collection_selection]
            samples = Sample.where(id: params[:collection_selection][0].values)
        end
        
        begin
             # Set a reasonable content type
             response.headers['Content-Type'] = 'application/zip'
             # Make sure nginx buffering is suppressed - see https://github.com/WeTransfer/zip_tricks/issues/48
             response.headers['X-Accel-Buffering'] = 'no'
             # Create a wrapper for the write call that quacks like something you
             response.headers["Content-Disposition"] = "attachment; filename=\"samples_combined.zip\""
             w = ZipTricks::BlockWrite.new { |chunk| response.stream.write(chunk) }
             ZipTricks::Streamer.open(w) { |zip| 
               zip.write_deflated_file("combined.csv") { |sink|
                samples.pluck_in_batches(:id, :type, batch_size: 2000) {|batch| 
                   batch.each{|id, type|
                     sample_type = type.constantize
                     sample_type.data_type.stream_csv_report(sample_type.data_type.where(sample_id: id)).lazy.each{|row|
                       sink.write(row)
                     }
                   }
                 }
               }
             }
       ensure
           response.stream.close
       end
    end
	
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

	index download_links: [:csv, :zip] do
		selectable_column
		id_column
        column :material
        column :user
		column :device

		column :file_name
		
		actions defaults: true do |instance|
			item "הורד", public_send("download_csv_admin_sample_path", instance.id), class: "member_link"
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
			params.permit(sample: [:user_id, :device])
		end  

		def scoped_collection
			super.includes :protocol
		end      
	end   
end