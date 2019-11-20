class ChangeInfluanceTypo < ActiveRecord::Migration[6.0]
  def change
    rename_column :usage_symptom_influances, :influance, :influence
    rename_table :usage_symptom_influances, :usage_symptom_influences
  end
end
