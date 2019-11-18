class RemoveNotNullFromUserBirthDate < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :birth_date
    add_column :users, :birth_date, :datetime
  end
end
