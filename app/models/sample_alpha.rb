class SampleAlpha < Sample
    has_many :data_records, dependent: :delete_all

    accepts_nested_attributes_for :data_records, :allow_destroy => true

    def data 
        self.data_records
    end

    def insert_csv(file_or_string)
        DataRecord.insert_csv(file_or_string, self)
    end

end
