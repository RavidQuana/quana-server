class UpdateUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :user_name, :string, null: false
    add_column :users, :phone_number, :string, null: false, unique: true
    add_column :users, :birth_date, :datetime, null: false
    add_column :users, :requires_local_auth, :boolean
    add_column :users, :created_at, :datetime, null: false
    add_column :users, :updated_at, :datetime, null: false

  end
end
