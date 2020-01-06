ActiveAdmin.register Sample do
	menu url: -> { admin_samples_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

	actions :all

	filter :id
  filter :device
  filter :file_name
  filter :product, as: :select2_multiselect
  filter :brand, as: :select2_multiselect
  filter :protocol, as: :select2_multiselect
  filter :sampler, as: :select2_multiselect
  filter :card, as: :select2_multiselect
  filter :tags, as: :select2_multiselect
  filter :tags2, label: "Not in Tags", as: :select2_multiselect, not: true
  filter :note

  scope -> { "White" }, :white
  scope -> { "Manual" }, :manual
  scope -> { "User" }, :user


    #need to always show batch actions
    config.batch_actions = true
    config.scoped_collection_actions_if = -> { true }
    scoped_collection_action :download_csv_scope, method: :post, class: 'download-trigger member_link_scope',  title: "הורדה מופרד" do

        samples = scoped_collection_records
        if params[:collection_selection].present?
            samples = Sample.where(id: params[:collection_selection][0].values)
        end
        samples = samples.distinct
        
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
           GC.start(false, true)
       end
    end

    scoped_collection_action :download_csv_combined_scope, method: :post, class: 'download-trigger member_link_scope',  title: "הורדה מאוחד" do
        samples = scoped_collection_records
        if params[:collection_selection].present?
            pp params[:collection_selection]
            samples = Sample.where(id: params[:collection_selection][0].values)
        end
        samples = samples.distinct
          
        begin
             # Set a reasonable content type
             response.headers['Content-Type'] = 'application/zip'
             # Make sure nginx buffering is suppressed - see https://github.com/WeTransfer/zip_tricks/issues/48
             response.headers['X-Accel-Buffering'] = 'no'
             # Create a wrapper for the write call that quacks like something you
             response.headers["Content-Disposition"] = "attachment; filename=\"samples_combined.zip\""
             w = ZipTricks::BlockWrite.new { |chunk| response.stream.write(chunk) }
             ZipTricks::Streamer.open(w) { |zip| 
               first = true
               zip.write_deflated_file("combined.csv") { |sink|
                samples.pluck_in_batches(:id, :type, batch_size: 2000) {|batch| 
                   batch.each{|id, type|
                     sample_type = type.constantize
                     sample_type.data_type.stream_csv_report(sample_type.data_type.where(sample_id: id), first).lazy.each{|row|
                       sink.write(row)
                     }
                     first = false
                   }
                 }
               }
             }
       ensure
           response.stream.close
           GC.start(false, true)
       end
    end


  scoped_collection_action :train, method: :post, class: 'download-trigger member_link_scope',  title: "שלח ללמידה" do
    params.permit!
    MlController.train(params[:q])
    redirect_to collection_path, notice: "Processing request sent."
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
      GC.start(false, true)
		end
  end

	index download_links: [:csv, :zip] do
		selectable_column
    id_column
    column :brand 
    column :product
    column :sampler_type
    column :sampler
    column :card
    column :file_name
    column :tags do |instance|
        meta_tags instance.tags, :name
    end

    column :note
		
		actions defaults: true do |instance|
			item "Download", public_send("download_csv_admin_sample_path", instance.id), class: "member_link"
		end
  end
  
  form do |f|
		f.inputs I18n.t('active_admin.details', model: I18n.t('activerecord.models.app_settings.one')) do
			f.input :sampler, as: :select2, input_html: { data: { select2: { ajax: { url: '/admin/autocomplete/sampler' } } } }
			f.input :product, as: :select2, input_html: { data: { select2: { ajax: { url: '/admin/autocomplete/product' } } } }
			f.input :protocol, as: :select2
			f.input :card, as: :select2
			f.input :tags, as: :select2, multiple: true
			f.input :note
			f.input :files, as: :file, :input_html => { :multiple => true }
		end

		f.actions
	end

	controller do
    def create(*args)	
        if params['sample']['files'].present?
            @uploads = params['sample']['files'].lazy.map{|file|
                begin
                    type = Sample.detect_format(file.tempfile)
                    #rewind the file to read it again
                    file.tempfile.rewind

                    sample = nil
                    type.transaction do 
                        sample_meta = permitted_params['sample'].to_h
                        sample_meta[:file_name] = file.original_filename
                        sample = type.create!(sample_meta)
                        sample.insert_sample(file.tempfile)
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

    def show()
			redirect_to public_send("admin_#{resource.model_name.param_key}_path", resource)
		end

		def edit()
			redirect_to public_send("edit_admin_#{resource.model_name.param_key}_path", resource)
		end

		def permitted_params
			params.permit!
		end  

		def scoped_collection
			super.includes :protocol, :card, :brand, :product, :tags, :sampler, :sampler_type
		end      
	end   
end