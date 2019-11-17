class CreateSymptomCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :symptom_categories do |t|
      t.string :name, null: false
    end
  end
end
