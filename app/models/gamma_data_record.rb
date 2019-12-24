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
#  humidity        :integer
#  temp           :integer
#  fan_type       :string           not null
#

#This structure is a simple raw data table
#make sure you dont add stuff like after_create/after_destroy 
#because we dont create/destroy with models but directly with db (aka bulk insert/delete)
class GammaDataRecord < ApplicationRecord
    include Exportable
    exportable [
		{
            name: I18n.t('activerecord.models.gamma_data_record.other'),
            header: [
                :sample,
                :time,
                :card,
                :qcm_1,
                :qcm_2,
                :qcm_3,
                :qcm_4,
                :qcm_5,
                :temp,
                :humidity,
                :tags
            ],
			columns: [
                :sample_id,
                "(CAST(#{table_name}.time_ms as float) / 1000) as time",
                "cards.id",
                :qcm_1,
                :qcm_2,
                :qcm_3,
                :qcm_4,
                :qcm_5,
                :temp,
                :humidity,
               # "array( select tag_id from sample_tags where sample_id = #{table_name}.sample_id)"
               "array( #{SampleTag.where("sample_id = #{table_name}.sample_id").joins(:tag).select('tags.name').to_sql} )"
            ],
            joins: [
                :card
            ],
            order: {
                time_ms: :asc
            }
	 	}
	]
    
    belongs_to :sample
    has_one :brand, through: :sample
    has_many :tags, through: :sample
    has_one :card, through: :sample
    
    def self.insert_sample(file_or_string, sample)
        raise "sample id is null" if sample.nil? || sample.id.nil?
        raise "unimplemented"
        return GammaDataRecord.insert_all!(csv_data.to_a)
    end
end

