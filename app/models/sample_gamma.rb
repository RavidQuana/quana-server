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

class SampleGamma < Sample
    include Exportable
    
    has_many :beta_data_records, dependent: :delete_all, foreign_key: :sample_id

    accepts_nested_attributes_for :beta_data_records, :allow_destroy => true

    def data 
        self.beta_data_records
    end

    def insert_sample(file_or_string)
        GammaDataRecord.insert_sample(file_or_string, self)
    end

    def self.from_file(file)
        file.set_encoding("ASCII-8BIT")
        file.rewind

        records = []

        while !file.eof?
            #packet_id, message_id, opcode, data_len = file.read(6).unpack("vvCC")

            data_len = file.read(1).unpack("C").first

            #pp packet_id, message_id, opcode, data_len 

            data = file.read(data_len+1)
            #if opcode != 6
            #    pp "unkown opcode"
            #    next
            #end

            #pp data
            
            crc = data.last
            sensor_code, sample_id, sample_size = data.unpack("CvC")

            #pp sensor_code, sample_id, sample_size
            pp sample_size
            temperture, humidity, qcm1, qcm2, qcm3, qcm4, qcm5, time = data.byteslice(4, sample_size).unpack("vvVVVVVV")

            #pp  temperture, humidity, qcm1, qcm2, qcm3, qcm4, qcm5, time 

            records << {
                time: time,
                sensor_id: sensor_code,
                temp: temperture, 
                humidity: humidity, 
                qcm_1: qcm1, 
                qcm_2: qcm2, 
                qcm_3: qcm3, 
                qcm_4: qcm4, 
                qcm_5: qcm5, 
            }
        end

        records
    end

    def self.from_records(records, sampler, source, source_id, product, tags, note)
        samples = []
        sensor_data = records.group_by{|r| r.sensor_id}
        sensor_data.each{|sensor_id, data|
            data.sort_by!{|r| r.time}

            begin
                card = card.find_or_create_by(id: sensor_id) do |c|
                    c.name = sensor_id
                end
            rescue ActiveRecord::RecordNotUnique
                retry
            end

            sample = SampleGamma.create!(file_name: "binary.bin", source: source, product: product, card: card, sampler: sampler)
            if source_id.nil?
                source_id = sample.id
            end 
            sample.source_id = source_id
            sample.tags = tags
            sample.save!

            data.each{|r|
                r.sample_id = sample.id
            }
            BetaDataRecord.insert_all!(data)

            samples << sample
        }   
        samples
    end

    def self.data_type
        GammaDataRecord
    end

    def data_type
        GammaDataRecord
    end
    
    def self.test_data(n)
        (0..n).each{|i| SampleGamma.create!(file_name:"test_#{i}.csv", brand: Brand.last, device: "Test").insert_sample(File.open('./test/test_beta.csv')) }
    end
end
