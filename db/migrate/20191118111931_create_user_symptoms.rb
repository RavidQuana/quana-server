class CreateUserSymptoms < ActiveRecord::Migration[6.0]
  def change
    create_table :user_symptoms do |t|
      t.belongs_to :user
      t.belongs_to :symptom
      t.integer :severity
      t.timestamps
    end
  end
end
