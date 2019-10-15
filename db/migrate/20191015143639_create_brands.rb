class CreateBrands < ActiveRecord::Migration[6.0]
  def change
    create_table :brands do |t|
      t.string :name, null: false, index: true, unique: true
      t.string :note
    end
    add_column :samples, :brand_id, :integer, index: true
  end
end
