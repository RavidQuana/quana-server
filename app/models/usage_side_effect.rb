# == Schema Information
#
# Table name: usage_side_effects
#
#  id             :bigint           not null, primary key
#  usage_id       :bigint
#  side_effect_id :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class UsageSideEffect < ApplicationRecord  
    belongs_to :usage
    belongs_to :side_effect
end
