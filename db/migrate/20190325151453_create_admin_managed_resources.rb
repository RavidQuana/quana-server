class CreateAdminManagedResources < ActiveRecord::Migration[5.2]
  	def change
		create_table :admin_managed_resources do |t|
			t.string 			:class_name, null: false
			t.string 			:action, null: false

			t.timestamps		null: false
		end

		add_index :admin_managed_resources, [:class_name, :action], unique: true, name: 'admin_managed_resources_index'
  	end
end
