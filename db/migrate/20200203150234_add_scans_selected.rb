class AddScansSelected < ActiveRecord::Migration[6.0]
  def change
    add_column :samples, :selected, :boolean, nil: false, default: false, index: true
  end
end
