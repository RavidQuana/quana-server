class CreateBetaSupport < ActiveRecord::Migration[6.0]
  def change
    create_table :beta_data_records do |t|
      t.integer :sample_id, null: false, index: true
      t.decimal :secs_elapsed, null: false, :precision => 10, :scale => 4
      t.integer :qcm_1, null: false
      t.integer :qcm_2, null: false
      t.integer :qcm_3, null: false
      t.integer :qcm_4, null: false
      t.integer :qcm_5, null: false
      t.decimal :humidiy, null: true, :precision => 10, :scale => 4
      t.decimal :temp, null: true, :precision => 10, :scale => 4
    end
  end
end
