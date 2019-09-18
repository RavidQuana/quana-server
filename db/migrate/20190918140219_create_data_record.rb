class CreateDataRecord < ActiveRecord::Migration[6.0]
  def change
    create_table :data_records do |t|
      t.integer :sample_id, null: false, index: true
        
      t.string :read_id, null: false
      t.string :file_id, null: false
      t.string :food_label, null: false
      t.integer :card, null: false
      t.decimal :secs_elapsed, null: false, :precision => 10, :scale => 4
      t.string :ard_state, null: false
      t.decimal :msec, null: false, :precision => 10, :scale => 4
      t.decimal :si, null: false, :precision => 10, :scale => 4
      t.decimal :clean_duration, null: false, :precision => 10, :scale => 4
      t.integer :qcm_respond, null: false
      t.integer :qcm_1, null: false
      t.integer :qcm_2, null: false
      t.integer :qcm_3, null: false
      t.integer :qcm_4, null: false
      t.integer :qcm_5, null: false
      t.integer :qcm_6, null: false
      t.integer :qcm_7, null: false
      t.integer :ht_status, null: true
      t.integer :humidiy, null: true
      t.integer :temp, null: true
      t.string :fan_type, null: false
    end
  end
end
