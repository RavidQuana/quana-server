class CreateAppSettings < ActiveRecord::Migration[5.2]
  	def change
	    create_table :app_settings do |t|
	    	t.string			:key, index: true, null: false, unique: true
	    	t.string			:value
	    	t.integer			:data_type, default: 0
	    	t.string			:description, limit: 4096
	    	t.boolean			:is_client_accessible, default: false

	    	t.timestamps		null: false   	
	    end
  	end
end
