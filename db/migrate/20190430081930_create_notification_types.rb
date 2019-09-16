class CreateNotificationTypes < ActiveRecord::Migration[5.2]
  	def change
	    create_table :notification_types do |t|
	    	t.string            :name, index: true
	    	t.jsonb    			:body_pattern, default: { }
	    	t.integer			:client_action_id, index: true
	    	t.boolean 			:send_push, default: false
	    	t.boolean			:send_sms, default: false

	    	t.timestamps		null: false
	    end

	   	add_index :client_actions, "lower(name) varchar_pattern_ops", 
	   		name: 'index_notification_types_on_lowercase_name'
  	end
end
