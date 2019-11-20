# == Schema Information
#
# Table name: usage_symptom_influances
#
#  id              :bigint           not null, primary key
#  usage_id        :bigint
#  user_symptom_id :bigint
#  influance       :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class UsageSymptomInfluance < ApplicationRecord  
    belongs_to :usage
    belongs_to :user_symptom

    enum influance: {worse: 0, same: 1, better: 2}

end
