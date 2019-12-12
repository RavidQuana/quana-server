class AddMlVersionQuery < ActiveRecord::Migration[6.0]
  def change
    add_column :ml_versions, :query, :string, null: true, default: nil
  end
end
