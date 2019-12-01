# == Schema Information
#
# Table name: usages
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  product_id :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Usage < ApplicationRecord  
    belongs_to :user
    belongs_to :product
    has_many :usage_symptom_influences

end
