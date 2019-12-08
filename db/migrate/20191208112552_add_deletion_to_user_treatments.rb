class AddDeletionToUserTreatments < ActiveRecord::Migration[6.0]
  def change
    add_column :user_treatments, :deleted_at, :datetime
  end
end
