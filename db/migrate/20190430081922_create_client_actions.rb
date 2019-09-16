class CreateClientActions < ActiveRecord::Migration[5.2]
  	def change
	    create_table :client_actions do |t|
	    	t.string			:name, index: true, unique: true
	    	t.string			:required_linkable_type

	    	t.timestamps  		null: false    	
	    end

	    add_index :client_actions, "lower(name) varchar_pattern_ops", name: 'index_client_actions_on_lowercase_name'
  	end
end
