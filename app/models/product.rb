# == Schema Information
#
# Table name: products
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  brand_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pros       :string
#  cons       :string
#  has_mold   :boolean          default(FALSE), not null
#

class Product < ApplicationRecord
    include Autocompletable
    autocompletable query_by: ['products.name', 'brands.name'], display_as: "%{to_s}", joins: [:brand]

    belongs_to :brand
    has_many :samples
    has_many :usages


    def to_s
        "#{self.brand.name} #{self.name}"
    end
end
