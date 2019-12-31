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

class SampleAlpha < Sample
    include Exportable
    
    has_many :data_records, dependent: :delete_all, foreign_key: :sample_id

    accepts_nested_attributes_for :data_records, :allow_destroy => true

    def data 
        self.data_records
    end

    def insert_sample(file_or_string)
        DataRecord.insert_sample(file_or_string, self)
    end

    def self.data_type
        DataRecord
    end

    def data_type
        DataRecord
    end
    
    def self.test_data(n)
        (0..n).each{|i| SampleAlpha.create!(file_name:"test_#{i}.csv", brand: Brand.last,  device: "Test").insert_sample(File.open('./test/test.csv')) }
    end
end
