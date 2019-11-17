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
#

class SampleBeta < Sample
    include Exportable
    
    has_many :beta_data_records, dependent: :delete_all, foreign_key: :sample_id

    accepts_nested_attributes_for :beta_data_records, :allow_destroy => true

    def data 
        self.beta_data_records
    end

    def insert_csv(file_or_string)
        BetaDataRecord.insert_csv(file_or_string, self)
    end

    def self.data_type
        BetaDataRecord
    end

    def data_type
        BetaDataRecord
    end
    
    def self.test_data(n)
        (0..n).each{|i| BetaSampleAlpha.create!(file_name:"test_#{i}.csv", brand: Brand.last, device: "Test").insert_csv(File.open('./test/test_beta.csv')) }
    end
end
