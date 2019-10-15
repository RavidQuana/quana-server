class CreateHardwares < ActiveRecord::Migration[6.0]
  def change
    create_table :scanners do |t|
      t.string :name, null: false, unique: true
    end

    create_table :hardwares do |t|
      t.integer :scanner_id, null: false
      t.string :version, null: false
    end

    add_column :samples, :hardware_id, :integer, index: true
  end
end
