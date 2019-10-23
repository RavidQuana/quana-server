class ChangeVersionToName < ActiveRecord::Migration[6.0]
  def change
    rename_column :samplers, :version, :name
  end
end
