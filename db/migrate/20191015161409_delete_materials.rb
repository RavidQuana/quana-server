class DeleteMaterials < ActiveRecord::Migration[6.0]
  def change
    drop_table :materials
    add_column :samples, :material, :string, null: false, default: ""
    remove_column :samples, :material_id, :integer
  end
end
