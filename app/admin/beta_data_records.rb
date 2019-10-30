ActiveAdmin.register BetaDataRecord do
	menu url: -> { admin_beta_data_records_path(locale: I18n.locale) } 

	include Admin::Translatable
	include Admin::Exportable
	include Admin::Scopable 

    includes(:sample)

	actions :all

	filter :id
    filter :sample_id
    filter :material_id

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