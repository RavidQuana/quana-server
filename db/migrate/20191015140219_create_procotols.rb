class CreateProcotols < ActiveRecord::Migration[6.0]
  def change
    create_table :procotols do |t|
      t.string :name, null: false, unique: true
      t.string :description, null: false
    end
    add_column :samples, :protocol_id, :integer, index: true
  end
end
