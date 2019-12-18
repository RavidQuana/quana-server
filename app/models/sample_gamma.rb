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
