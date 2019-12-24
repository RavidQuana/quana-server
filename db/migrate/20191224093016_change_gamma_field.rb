class ChangeGammaField < ActiveRecord::Migration[6.0]
  def change
    SampleGamma.destroy_all
    rename_column :gamma_data_records, :secs_elapsed, :time_ms
    rename_column :gamma_data_records, :humidiy, :humidity
    add_column :gamma_data_records, :sample_code, :integer, null: false
  end
end
