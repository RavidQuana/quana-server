class CreateUsageSymptomInfluances < ActiveRecord::Migration[6.0]
  def change
    create_table :usage_symptom_influances do |t|
      t.belongs_to :usage
      t.belongs_to :user_symptom
      t.column :influance, :integer, null: false
      t.timestamps

    end
  end
end
