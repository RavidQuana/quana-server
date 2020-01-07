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
#  sampler_id  :integer
#  card_id     :integer
#  note        :string
#  product_id  :integer          not null
#  source      :integer          default("manual"), not null
#  source_id   :integer
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
    has_many :tags2, through: :sample_tags, source: :tag

    enum source: { manual: 0, white: 1, user: 2 }    

    scope :no_tags, -> { where("(select count(id) from sample_tags where samples.id = sample_tags.sample_id) = 0") }
    scope :has_tags, -> { where("(select count(id) from sample_tags where samples.id = sample_tags.sample_id) > 0") }

    def self.MigrateDummy1
        #BetaDataRecord.all.delete_all
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
                    temp: d.qcm_6,
                    humidiy: d.qcm_7,
                )
            }
    
            Sample.all.update_all(type: "SampleBeta")
            #DataRecord.all.delete_all
        end
    end

    def data
        raise "no data"
    end

    def self.ransackable_scopes(auth_object = nil)
        [:manual, :white, :user]
    end


    def classification
        MlController.classify_sample(self)
    end

    def file_id
        data.first.file_id
    end

    def files=(val)
        #dummy function to make stuff work
        #do not remove
    end

    def self.detect_format(file_or_string) 
        begin 
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
        rescue => e

        ensure   
            if !file_or_string.is_a?(String)
                file_or_string.rewind
            end  
        end

        return SampleGamma

        if file_or_string.is_a?(String)
            file_or_string = StringIO.new(file_or_string)
        end
        file_or_string.set_encoding("ASCII-8BIT")
        header = file_or_string.read(5)

        op = header[4].unpack("C")[0]
        if op == 0x06
            return SampleGamma
        end

        return nil
    end

    def temp_file
        require 'tempfile'
        file = Tempfile.new('sample.csv')
        self.data_type.stream_csv_report(self.data).lazy.each{|row|
            file.write(row)
        }
        file.flush
        file.rewind
        file
    end
end
