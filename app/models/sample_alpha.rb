class SampleAlpha < Sample
    include Exportable
    
    has_many :data_records, dependent: :delete_all, foreign_key: :sample_id

    accepts_nested_attributes_for :data_records, :allow_destroy => true

    def data 
        self.data_records
    end

    def insert_csv(file_or_string)
        DataRecord.insert_csv(file_or_string, self)
    end

    def self.data_type
        DataRecord
    end

    def data_type
        DataRecord
    end
    
    def self.test_data
        (0..10000).each{|i| SampleAlpha.create!(file_name:"test_#{i}.csv", material: Material.last, device: "Test").insert_csv(File.open('./test/test.csv')) }
    end
end
