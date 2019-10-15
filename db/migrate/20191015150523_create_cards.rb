class CreateCards < ActiveRecord::Migration[6.0]
  def change
    create_table :cards do |t|
      t.string :name, null: false, index: true, unique: true
    end

    add_column :samples, :card_id, :integer, index: true
  end
end
