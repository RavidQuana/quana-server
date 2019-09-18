ActiveAdmin.register DataRecord do
	menu url: -> { admin_data_records_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

    includes(:sample)

	actions :all

	filter :idvv
    filter :sample_id
    filter :material_id

	index do
		selectable_column
		id_column
        
        column :sample
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

	controller do
		def permitted_params
			params.permit! 
		end  

		def scoped_collection
			super.includes :sample
		end      
	end   
end