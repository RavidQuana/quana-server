class UpdateUsersCredentials < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    remove_column :users, :user_name
    remove_column :users, :phone_number
    add_column :users, :phone_number, :string, null: false, unique: true, index: true
  end
end
