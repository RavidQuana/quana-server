class RemoveMaterial < ActiveRecord::Migration[6.0]
  def change
    remove_column :samples, :material
  end
end
