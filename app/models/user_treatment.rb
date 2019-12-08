# == Schema Information
#
# Table name: user_treatments
#
#  id           :bigint           not null, primary key
#  user_id      :bigint
#  treatment_id :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  deleted_at   :datetime
#

class UserTreatment < ApplicationRecord  
    scope :deleted, ->  {where(deleted_at: nil)} 
    default_scope {deleted}

    belongs_to :user
    belongs_to :treatment

    validates :treatment_id, uniqueness: {scope: :user_id, conditions: -> {deleted}}#,  unless: :deleted?

    
end
