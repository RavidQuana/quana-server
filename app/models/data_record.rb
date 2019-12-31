# == Schema Information
#
# Table name: data_records
#
#  id           :bigint           not null, primary key
#  sample_id    :integer          not null
#  secs_elapsed :decimal(10, 4)   not null
#  qcm_1        :integer          not null
#  qcm_2        :integer          not null
#  qcm_3        :integer          not null
#  qcm_4        :integer          not null
#  qcm_5        :integer          not null
#  qcm_6        :integer          not null
#  qcm_7        :integer          not null
#  humidiy      :integer
#  temp         :integer
#

#This structure is a simple raw data table
#make sure you dont add stuff like after_create/after_destroy 
#because we dont create/destroy with models but directly with db (aka bulk insert/delete)
class DataRecord < ApplicationRecord
    include Exportable
    exportable [
		{
            name: I18n.t('activerecord.models.data_record.other'),
            header: [
                :sample,
                :time,
                :card,
                :qcm_1,
                :qcm_2,
                :qcm_3,
                :qcm_4,
                :qcm_5,
                :qcm_6,
                :qcm_7,
                :temp,
                :humidiy,
                :tags
            ],
			columns: [
                :sample_id,
                :secs_elapsed,
                "cards.id",
                :qcm_1,
                :qcm_2,
                :qcm_3,
                :qcm_4,
                :qcm_5,
                :qcm_6,
                :qcm_7,
                :temp,
                :humidiy,
                "array(select tag_id from sample_tags where sample_id = #{table_name}.sample_id)"
            ],
            joins: [
                :card
            ],
            order: {
                secs_elapsed: :asc
            }
	 	}
	]

    belongs_to :sample
    has_one :brand, through: :sample
    has_many :tags, through: :sample
    has_one :card, through: :sample
    
    def self.insert_sample(file_or_string, sample)
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
        return DataRecord.insert_all!(csv_data.to_a)
    end
end
