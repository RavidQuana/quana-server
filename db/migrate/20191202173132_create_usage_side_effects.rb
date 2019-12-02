class CreateUsageSideEffects < ActiveRecord::Migration[6.0]
  def change
    create_table :usage_side_effects do |t|
      t.belongs_to :usage
      t.belongs_to :side_effect
      t.timestamps
    end
  end
end
