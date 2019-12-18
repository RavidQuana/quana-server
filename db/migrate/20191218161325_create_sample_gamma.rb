class CreateSampleGamma < ActiveRecord::Migration[6.0]
  def change
    create_table :gamma_data_records do |t|
      t.integer :sample_id, null: false, index: true
      t.integer :secs_elapsed, null: false
      t.integer :sensor_code, null: false
      t.integer :qcm_1, null: false
      t.integer :qcm_2, null: false
      t.integer :qcm_3, null: false
      t.integer :qcm_4, null: false
      t.integer :qcm_5, null: false
      t.integer :humidiy, null: true
      t.integer :temp, null: true
    end
  end 
end
  