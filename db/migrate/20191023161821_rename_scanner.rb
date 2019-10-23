class RenameScanner < ActiveRecord::Migration[6.0]
  def change
    rename_column :samplers, :scanner_id, :sampler_type_id
  end
end
