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

class SampleGamma < Sample
    include Exportable
    
    has_many :gamma_data_records, -> { order(time_ms: :asc) }, dependent: :delete_all, foreign_key: :sample_id
    accepts_nested_attributes_for :gamma_data_records, :allow_destroy => true

    def data 
        self.gamma_data_records
    end

    def data_time_column
        :time_ms
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

            #data_len = file.read(1).unpack("C").first

            #pp packet_id, message_id, opcode, data_len 

            #data = file.read(data_len+1)
            #if opcode != 6
            #    pp "unkown opcode"
            #    next
            #end

            #pp data
            
            #crc = data.last
            data = file.read(4)
            sensor_code, sample_id, sample_size = data.unpack("CvC")
            data = file.read(sample_size+1)
            #pp sensor_code, sample_id, sample_size
            #pp sensor_code, sample_id, sample_size

            samples = data.unpack("C")[0]
            data = data.byteslice(1..-1)

            for i in 0...samples 
                card_id, time, temperture, humidity, qcm1, qcm2, qcm3, qcm4, qcm5  = data.unpack("CVvvVVVVV")

                records << {
                    sample_code: sample_id,
                    time_ms: time,
                    sensor_code: card_id,
                    temp: temperture, 
                    humidity: humidity, 
                    qcm_1: qcm1, 
                    qcm_2: qcm2, 
                    qcm_3: qcm3, 
                    qcm_4: qcm4, 
                    qcm_5: qcm5, 
                }

                data = data.byteslice(29..-1)
            end
            crc = data.unpack("C")
        end

        records
    end

    def self.from_records(records, sampler, source, source_id, product, tags, note)
        samples = []
        SampleGamma.transaction do 
            sensor_data = records.group_by{|r| r[:sensor_code]}
            sensor_data.each{|sensor_code, data|
                data.sort_by!{|r| r[:time_ms]}
    
                begin
                    card = Card.find_or_create_by(id: sensor_code) do |c|
                        c.name = sensor_code
                    end
                rescue ActiveRecord::RecordNotUnique
                    retry
                end
                
                sample = SampleGamma.create!(file_name: "sample.csv", protocol: Protocol.last, source: source, product: product, card: card, sampler: sampler, note: note)
                if source_id.nil?
                    source_id = sample.id
                end 
                sample.source_id = source_id
                sample.tags = tags if tags.size > 0
                sample.save!
    
                data.each{|r|
                    r[:sample_id] = sample.id
                }

                GammaDataRecord.insert_all!(data)
    
                samples << sample
            }   
        end
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
