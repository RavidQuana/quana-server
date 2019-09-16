class CreateDevices < ActiveRecord::Migration[5.2]
  	def change
	    create_table :devices do |t|
	    	t.integer			:owner_id
	    	t.string			:owner_type
	    	t.string			:device_token, index: true
	    	t.integer			:os_type
	    	t.string			:device_type
	    	t.string			:os_version
	    	t.string			:app_version
	    	t.integer			:failed_attempts, default: 0
	        t.boolean           :is_sandbox, default: false

	    	t.timestamps    	null: false	
	    end

	    add_index :devices, [:owner_id, :owner_type], name: 'index_devices_on_owner'
  	end
end
