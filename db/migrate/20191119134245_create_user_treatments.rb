class CreateUserTreatments < ActiveRecord::Migration[6.0]
  def change
    create_table :user_treatments do |t|
      t.belongs_to :user
      t.belongs_to :treatment
      t.timestamps
    end
  end
end
