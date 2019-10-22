# == Schema Information
#
# Table name: brands
#
#  id   :bigint           not null, primary key
#  name :string           not null
#  note :string
#

class Brand < ApplicationRecord
    has_many :samples

    def samples_count
        self.samples.count
    end
end
