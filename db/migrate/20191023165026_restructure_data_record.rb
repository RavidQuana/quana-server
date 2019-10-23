class RestructureDataRecord < ActiveRecord::Migration[6.0]
  def change
    # == Schema Information
#
# Table name: data_records
#
#  id             :bigint           not null, primary key
#  sample_id      :integer          not null
#  read_id        :string           not null
#  file_id        :string           not null
#  food_label     :string           not null
#  card           :integer          not null
#  secs_elapsed   :decimal(10, 4)   not null
#  ard_state      :string           not null
#  msec           :decimal(10, 4)   not null
#  si             :decimal(10, 4)   not null
#  clean_duration :decimal(10, 4)   not null
#  qcm_respond    :integer          not null
#  qcm_1          :integer          not null
#  qcm_2          :integer          not null
#  qcm_3          :integer          not null
#  qcm_4          :integer          not null
#  qcm_5          :integer          not null
#  qcm_6          :integer          not null
#  qcm_7          :integer          not null
#  ht_status      :integer
#  humidiy        :integer
#  temp           :integer
#  fan_type       :string           not null
#
    remove_column :data_records, :read_id
    remove_column :data_records, :file_id
    remove_column :data_records, :food_label
    remove_column :data_records, :card
    remove_column :data_records, :ard_state
    remove_column :data_records, :msec
    remove_column :data_records, :si
    remove_column :data_records, :clean_duration
    remove_column :data_records, :qcm_respond
    remove_column :data_records, :ht_status
    remove_column :data_records, :fan_type
  end
end


