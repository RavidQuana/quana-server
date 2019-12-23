class AddProductBrandUnique < ActiveRecord::Migration[6.0]
  def change
    add_index :products, [:name, :brand_id], unique: true 
  end 
end
