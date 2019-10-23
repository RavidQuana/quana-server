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

#This structure is a simple raw data table
#make sure you dont add stuff like after_create/after_destroy 
#because we dont create/destroy with models but directly with db (aka bulk insert/delete)
class DataRecord < ApplicationRecord
    include Exportable
    exportable [
		{
			name: I18n.t('activerecord.models.data_record.other'),
			columns: [
                :secs_elapsed,
                :qcm_1,
                :qcm_2,
                :qcm_3,
                :qcm_4,
                :qcm_5,
                :qcm_6,
                :qcm_7,
                :temp,
                :humidiy,
            ],
            joins: [
                
            ]
	 	}
	]

    belongs_to :sample
    has_one :brand, through: :sample
    
    def self.insert_csv(file_or_string, sample)
        raise "sample id is null" if sample.nil? || sample.id.nil?
        require 'rcsv'
        csv_data = Enumerator.new do |y|
            Rcsv.parse(file_or_string, headers: :skip).each_with_index{|row, index|
                next if index <= 3
				y << {
                    sample_id: sample.id,
                    secs_elapsed: row[0],
                    qcm_1: row[1],
                    qcm_2: row[2],
                    qcm_3: row[3],
                    qcm_4: row[4],
                    qcm_5: row[5],
                    qcm_6: row[6],
                    qcm_7: row[7],
                    temp: row[8],
                    humidiy: row[9]
				}
			}
        end
        DataRecord.insert_all!(csv_data.to_a)
    end
end
