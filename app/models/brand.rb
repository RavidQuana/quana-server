class Brand < ApplicationRecord
    has_many :samples

    def samples_count
        self.samples.count
    end
end