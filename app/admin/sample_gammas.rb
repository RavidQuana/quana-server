ActiveAdmin.register SampleGamma do
    menu :if => proc{ false }   

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

	actions :all

	filter :id
	
	index download_links: [:csv, :zip, :zip_records, :zip_records_combined]

	collection_action :download_samples, method: :post do
		pp collection
		# Do some CSV importing work here...
		redirect_to collection_path, notice: "CSV imported successfully!"
	end

	action_item :view, only: :index do
		#link_to 'View on site', download_samples_admin_samples_path(request.parameters[:q])
	end
	
	index do
		selectable_column
		id_column
        
        column :user
		column :sampler

		column :file_name
		
        actions defaults: true do |instance|
			item "הורד", public_send("download_csv_admin_sample_path", instance.id), class: "member_link"
		end
	end

	show do 
		panel I18n.t('active_admin.details', model: I18n.t('activerecord.models.sample_gamma.one')) do
			attributes_table_for sample_gamma do
				row :id
				row :sampler_type
				row :sampler
				row :brand
				row :product
				row :card
				row :file_name
				row :classification
			  	row :created_at
				row :updated_at 

				data = sample_gamma.gamma_data_records.sort_by{|d| d.time}
				  
				table_for data do
					column :id do |instance|
						link_to instance.id, public_send("admin_#{sample_gamma.data_type.model_name.param_key}_path", instance.id)
					end
					column :time
					column :qcm_1
					column :qcm_2
					column :qcm_3
					column :qcm_4
					column :qcm_5
					column :temp
					column :humidity
                end

				if data.count > 0 
                    min_max = data.map{|row| [
                        row.qcm_1,
                        row.qcm_2,
                        row.qcm_3,
                        row.qcm_4,
						row.qcm_5]}.flatten.minmax { |a, b| a <=> b }
						
					data = data[10..-1]	
    
                    space = (min_max[1] - min_max[0]) * 0.1
    
					h1 "Absolute Graphs"

                    div line_chart [
                        {name: "qcm_1", data: data.map { |data_record| [data_record.time, data_record.qcm_1] }},
                        {name: "qcm_2", data: data.map { |data_record| [data_record.time, data_record.qcm_2] }},
                        {name: "qcm_3", data: data.map { |data_record| [data_record.time, data_record.qcm_3] }},
                        {name: "qcm_4", data: data.map { |data_record| [data_record.time, data_record.qcm_4] }},
                        {name: "qcm_5", data: data.map { |data_record| [data_record.time, data_record.qcm_5] }},
                    ], min: min_max[0]-space, max: min_max[1]+space, points: false
    
                    div line_chart [
                        {name: "humidity", data: data.map { |data_record| [data_record.time, data_record.humidity] }},
                        {name: "temp", data: data.map { |data_record| [data_record.time, data_record.temp] }},
					], points: false

					h1 "Relative Graphs"
					
					div line_chart [
                        {name: "qcm_1", data: data.map { |data_record| [data_record.time, data_record.qcm_1.to_i - data[10].qcm_1.to_i] }},
                        {name: "qcm_2", data: data.map { |data_record| [data_record.time, data_record.qcm_2.to_i - data[10].qcm_2.to_i] }},
                        {name: "qcm_3", data: data.map { |data_record| [data_record.time, data_record.qcm_3.to_i - data[10].qcm_3.to_i] }},
                        {name: "qcm_4", data: data.map { |data_record| [data_record.time, data_record.qcm_4.to_i - data[10].qcm_4.to_i] }},
                        {name: "qcm_5", data: data.map { |data_record| [data_record.time, data_record.qcm_5.to_i - data[10].qcm_5.to_i] }},
                    ], points: false
    
					div line_chart [
                        {name: "humidity", data: data.map { |data_record| [data_record.time, data_record.humidity.to_f - data[10].humidity.to_f] }},
                        {name: "temp", data: data.map { |data_record| [data_record.time, data_record.temp.to_f - data[10].temp.to_f] }},
					], points: false
                end
            end
            
           
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


=begin disabled for now
			f.inputs do
				f.has_many :gamma_data_records, heading: 'Data Records',
							allow_destroy: true,
							new_record: true do |a|
					a.input :time
					a.input :qcm_1
					a.input :qcm_2
					a.input :qcm_3
					a.input :qcm_4
					a.input :qcm_5
					a.input :temp
					a.input :humidity
				end
			end
=end

		end

		f.actions
	end

	controller do
        def create(*args)	
            if params['sample_gamma']['files'].present?
                @uploads = params['sample_gamma']['files'].lazy.map{|file|
                    begin
                        sample = nil
                        SampleGamma.transaction do 
                            sample_meta = permitted_params['sample_gamma'].to_h
                            sample_meta[:file_name] = file.original_filename
                            sample = SampleGamma.create!(sample_meta)
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

		def update(*args)
			sample = nil
			SampleGamma.transaction do 
				id = params['id']
				SampleGamma.find(id).update!(permitted_params['sample_gamma'])
				params['sample_gamma']['files'].each{|file|
					#sample = SampleGamma.create!(permitted_params['sample'])
					#sample.insert_sample(file.tempfile)
				} if params['sample_gamma']['files'].present?
				redirect_to collection_url(locale: I18n.locale) and return
			end

			flash.now[:error] = sample.errors.full_messages.join(', ')
			render :new
		end

		def permitted_params
            params.permit!
		end  

		def scoped_collection
			super
		end      
	end   
end