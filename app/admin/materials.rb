ActiveAdmin.register Material do
	menu url: -> { admin_materials_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

	actions :all

	filter :id
    filter :name
	
	member_action :download_zip, method: :get do
		
	end

	member_action :download_zip_combined, method: :get do
		
	end


	index do
		selectable_column
		id_column
		column :name
		column :samples_count
		
		actions defaults: true do |instance|
			item "הורד", download_zip_admin_material_path(instance), class: "member_link"
			item "הורד משולב", download_zip_combined_admin_material_path(instance), class: "member_link"
		end
	end

	
	index download_links: [:csv, :zip]

	controller do
		def permitted_params
			params.permit! 
		end  

        def download_zip
			scoped_collection_records = resource.samples
			
			 # Set a reasonable content type
			 response.headers['Content-Type'] = 'application/zip'
			 # Make sure nginx buffering is suppressed - see https://github.com/WeTransfer/zip_tricks/issues/48
			 response.headers['X-Accel-Buffering'] = 'no'
			 # Create a wrapper for the write call that quacks like something you
             response.headers["Content-Disposition"] = "attachment; filename=\"material-#{resource.id}.zip\""
             
         
             self.response_body = Enumerator.new do |yielder|
                 w = ZipTricks::BlockWrite.new { |chunk| 
                   yielder << chunk 
                 }
                 ZipTricks::Streamer.open(w) { |zip| 
                    scoped_collection_records.pluck_in_batches(:id, :type, :file_name, batch_size: 500) {|batch| 
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
             end

		end

		def download_zip_combined
			scoped_collection_records = resource.samples
			
			 # Set a reasonable content type
			 response.headers['Content-Type'] = 'application/zip'
			 # Make sure nginx buffering is suppressed - see https://github.com/WeTransfer/zip_tricks/issues/48
			 response.headers['X-Accel-Buffering'] = 'no'
			 response.headers["Content-Disposition"] = "attachment; filename=\"material-combined-#{resource.id}.zip\""
             # Create a wrapper for the write call that quacks like something you
             
             self.response_body = Enumerator.new do |yielder|
                w = ZipTricks::BlockWrite.new { |chunk| 
                  yielder << chunk 
                }
                ZipTricks::Streamer.open(w) { |zip| 
                    zip.write_deflated_file("combined.csv") { |sink|
                        scoped_collection_records.pluck_in_batches(:id, :type, batch_size: 2000) {|batch| 
                            batch.each{|id, type|
                                sample_type = type.constantize
                                sample_type.data_type.stream_csv_report(sample_type.data_type.where(sample_id: id)).lazy.each{|row|
                                    sink.write(row)
                                }
                            }
                        }
                    }
                }
            end
		end
	end   
end