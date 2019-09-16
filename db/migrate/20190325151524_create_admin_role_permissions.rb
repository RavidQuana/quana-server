class CreateAdminRolePermissions < ActiveRecord::Migration[5.2]
  	def change
		create_table :admin_role_permissions do |t|
			t.integer			:admin_role_id, index: true, null: false
			t.integer 			:admin_managed_resource_id, index: true, null: false

			t.timestamps		null: false
		end

		add_index :admin_role_permissions, [:admin_role_id, :admin_managed_resource_id], unique: true, 
			name: 'admin_role_permissions_index'
  	end
end
