class AddUserColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :cannabis_use_years, :integer, null: false, default: 0
    add_column :users, :cannabis_use_monthes, :integer, null: false, default: 0
    add_column :users, :cannabis_use_frequency, :string, null: true
    add_column :users, :blood_sugar_medications, :boolean, null: false, default: false

  end
end
