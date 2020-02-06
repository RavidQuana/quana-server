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
    has_many :usage_side_effects, through: :usages
    has_many :side_effects, through: :usage_side_effects


    def to_s
        "#{self.brand.name} #{self.name}"
    end


    def stats_by_user(user_id)
        result = ProductStat.new(product: self)
        result.usage_count = self.user_usages(user_id).count
        result.side_effects = self.user_side_effects(user_id)
        result 
    end
    
    def user_side_effects(user_id)
        self.side_effects.joins(:usages).where(usages:{user_id:user_id}).distinct
    
    end

    def user_usages(user_id)
        self.usages.where(user_id:user_id)
    
    end
end
