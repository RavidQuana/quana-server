class CreateNotifications < ActiveRecord::Migration[5.2]
  	def change
	    create_table :notifications do |t|
	    	t.integer			:sender_id
	    	t.string			:sender_type
	    	t.integer			:receiver_id
	    	t.string			:receiver_type
	    	t.integer			:notification_type_id, index: true
	    	t.string			:body, limit: 4096
			t.integer			:linkable_id
			t.string			:linkable_type
	    	t.integer			:delivery_status, default: 0
	    	t.boolean			:is_visible, default: true

	    	t.timestamps		null: false
	    end

	    add_index :notifications, [:sender_id, :sender_type], name: 'index_notifications_on_sender'
	    add_index :notifications, [:receiver_id, :receiver_type], name: 'index_notifications_on_receiver'
	    add_index :notifications, [:linkable_id, :linkable_type], name: 'index_notifications_on_linkable' 
  	end
end