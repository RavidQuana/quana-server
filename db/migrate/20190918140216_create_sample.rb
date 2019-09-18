class CreateSample < ActiveRecord::Migration[6.0]
  def change
    create_table :samples do |t|
      t.string :type, null: false, index: true
      t.integer :material_id, null: false, index: true
      t.integer :user_id, null: true, index: true, default: nil
      t.string :device, null: true

      t.timestamps
    end
  end
end
