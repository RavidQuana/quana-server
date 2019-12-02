class AddProductFields < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :pros, :string, null: true
    add_column :products, :cons, :string, null: true
    add_column :products, :has_mold, :boolean, null: false, default: false

  end
end
