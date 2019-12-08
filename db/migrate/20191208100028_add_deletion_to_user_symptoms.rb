class AddDeletionToUserSymptoms < ActiveRecord::Migration[6.0]
  def change
    add_column :user_symptoms, :deleted_at, :datetime
    add_column :user_symptoms, :delete_reason, :string
  end
end
