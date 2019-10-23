# == Schema Information
#
# Table name: brands
#
#  id   :bigint           not null, primary key
#  name :string           not null
#  note :string
#

class Brand < ApplicationRecord
    has_many :products
    has_many :samples, through: :products

    def samples_count
        self.samples.count
    end
end
