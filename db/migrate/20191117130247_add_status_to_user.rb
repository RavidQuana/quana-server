class AddStatusToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :status, :integer, null: false, default: 0
    add_column :users, :gender, :integer, null: false, default: 0
    add_column :users, :last_activity_at, :datetime


    
  end
end
