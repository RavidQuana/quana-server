# == Schema Information
#
# Table name: products
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  brand_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Product < ApplicationRecord
    include Autocompletable
    autocompletable query_by: ['products.name', 'brands.name'], display_as: "%{to_s}", joins: [:brand]

    belongs_to :brand
    has_many :samples

    def to_s
        "#{self.brand.name} #{self.name}"
    end
end
