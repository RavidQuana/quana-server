class CreateAdminRoles < ActiveRecord::Migration[5.2]
  	def change
		create_table :admin_roles do |t|
			t.string 			:name, index: true, null: false
			t.string 			:display_name, index: true, null: false

			t.timestamps		null: false
		end

		add_index :admin_roles, "(id::text) varchar_pattern_ops", name: 'index_admin_roles_on_id_text'
		add_index :admin_roles, "lower(name) varchar_pattern_ops", name: 'index_admin_roles_on_lowercase_name'
		add_index :admin_roles, "lower(display_name) varchar_pattern_ops", name: 'index_admin_roles_on_lowercase_display_name'
  	end
end
