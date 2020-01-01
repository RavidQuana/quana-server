# == Schema Information
#
# Table name: gamma_data_records
#
#  id          :bigint           not null, primary key
#  sample_id   :integer          not null
#  time_ms     :integer          not null
#  sensor_code :integer          not null
#  qcm_1       :integer          not null
#  qcm_2       :integer          not null
#  qcm_3       :integer          not null
#  qcm_4       :integer          not null
#  qcm_5       :integer          not null
#  humidity    :integer
#  temp        :integer
#  sample_code :integer          not null
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
                #return this after migration 
               #"array( #{SampleTag.where("sample_id = #{table_name}.sample_id").joins(:tag).select('tags.name').to_sql} )"
               "array(SELECT tags.name FROM \"sample_tags\" INNER JOIN \"tags\" ON \"tags\".\"id\" = \"sample_tags\".\"tag_id\" WHERE (sample_id = #{table_name}.sample_id)"
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
    
    def time
        self.time_ms.to_f / 1000
    end

    def self.insert_sample(file_or_string, sample)
        raise "sample id is null" if sample.nil? || sample.id.nil?
        raise "unimplemented"
        return GammaDataRecord.insert_all!(csv_data.to_a)
    end
end

