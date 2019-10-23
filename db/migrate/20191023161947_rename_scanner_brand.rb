class RenameScannerBrand < ActiveRecord::Migration[6.0]
  def change
    rename_column :samples, :hardware_id, :sampler_id
    remove_column :samples, :brand_id
  end
end
