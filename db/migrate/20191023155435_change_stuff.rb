class ChangeStuff < ActiveRecord::Migration[6.0]
  def change
    Sample.all.destroy_all

    rename_table("scanners", "sampler_types")
    rename_table("hardwares", "samplers")
    remove_column :samples, :repetition
    create_table :products do |t|
      t.string :name, index: true, null: false
      t.integer :brand_id, index: true, null: false
    
      t.timestamps
    end
    
    add_column :samples, :fan_speed, :integer, null: false, default: 0
    add_column :samples, :product_id, :integer, index: true, null: false
  end
end
