ActiveAdmin.register DataRecord do
	#menu url: -> { admin_data_records_path(locale: I18n.locale) } 
	menu false

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

    includes(:sample)

	actions :all

	filter :id
    filter :sample_id

	index do
		selectable_column
		id_column
        
        column :sample
        column :secs_elapsed
        column :qcm_1
        column :qcm_2
        column :qcm_3
        column :qcm_4
        column :qcm_5
        column :qcm_6
        column :qcm_7
        column :temp
        column :humidiy

        actions defaults: true do |instance|
		end
	end

	controller do
		def permitted_params
			params.permit! 
		end  

		def scoped_collection
			super.includes :sample
		end      
	end   
end