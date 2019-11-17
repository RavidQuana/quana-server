class CreateSymptoms < ActiveRecord::Migration[6.0]
  def change
    create_table :symptoms do |t|
            t.references :symptom_category, foreign_key: true
            t.string :name, null: false, unique: true
            t.timestamps
    end
  end
end
