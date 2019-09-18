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

class DataRecord < ApplicationRecord
    include Exportable

    belongs_to :sample
    has_one :material, through: :sample

    def self.insert_csv(file_or_string, sample_id)
        require 'rcsv'
        csv_data = Enumerator.new do |y|
			Rcsv.parse(file_or_string, headers: :skip).each{|row|
				y << {
                    sample_id: sample_id,
                    read_id: row[0],
                    file_id: row[1],
                    food_label: row[2],
                    card: row[3],
                    secs_elapsed: row[4],
                    ard_state: row[5],
                    msec: row[6],
                    si: row[7],
                    clean_duration: row[8],
                    qcm_respond: row[9],
                    qcm_1: row[10],
                    qcm_2: row[11],
                    qcm_3: row[12],
                    qcm_4: row[13],
                    qcm_5: row[14],
                    qcm_6: row[15],
                    qcm_7: row[16],
                    ht_status: row[17],
                    humidiy: row[18],
                    temp: row[19],
                    fan_type: row[20],
				}
			}
        end
        DataRecord.insert_all(csv_data.to_a)
    end


end