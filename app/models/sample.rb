# == Schema Information
#
# Table name: samples
#
#  id          :bigint           not null, primary key
#  type        :string           not null
#  user_id     :integer
#  device      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  file_name   :string           default(""), not null
#  protocol_id :integer
#  brand_id    :integer
#  hardware_id :integer
#  card_id     :integer
#  note        :string
#  material    :string           default("Material"), not null
#  fan_speed   :integer          default(0), not null
#  product_id  :integer          not null
#

class Sample < ApplicationRecord
    include Exportable

    belongs_to :user, optional: true
    belongs_to :protocol
    belongs_to :product
    belongs_to :sampler
    belongs_to :card
    has_one :sampler_type, through: :sampler
    has_one :brand, through: :product

    has_many :sample_tags
    has_many :tags, through: :sample_tags

    def self.MigrateDummy1
        BetaDataRecord.transaction do 
            DataRecord.all.each{|d|
                BetaDataRecord.create!(
                    sample_id: d.sample_id,
                    secs_elapsed: d.secs_elapsed,
                    qcm_1: d.qcm_1,
                    qcm_2: d.qcm_2,
                    qcm_3: d.qcm_3,
                    qcm_4: d.qcm_4,
                    qcm_5: d.qcm_5,
                    temp: d.qcm_7,
                    humidiy: d.qcm_7,
                )
            }
    
            Sample.all.update_all(type: "SampleBeta")
            DataRecord.all.delete_all
        end
    end

    def data
        raise "no data"
    end

    def file_id
        data.first.file_id
    end

    def files=(val)
        #dummy function to make stuff work
        #do not remove
    end

    def self.detect_format(file_or_string) 
        require 'rcsv'
        Rcsv.parse(file_or_string, headers: :skip).each_with_index{|row, index|
            if index == 0 
                return SampleAlpha if row[0] == "Time" 
            end
            if index == 0
                return SampleBeta if row[0] == "TimeCount" 
            end
            break if index > 1
        }
        return nil
    end
end
