class CreateMlVersion < ActiveRecord::Migration[6.0]
  def change
    create_table :ml_versions do |t|
      t.string :name, null: false, index: true
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end 
end
