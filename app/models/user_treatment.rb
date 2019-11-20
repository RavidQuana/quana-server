# == Schema Information
#
# Table name: user_treatments
#
#  id           :bigint           not null, primary key
#  user_id      :bigint
#  treatment_id :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class UserTreatment < ApplicationRecord  
    belongs_to :user
    belongs_to :treatment
end
