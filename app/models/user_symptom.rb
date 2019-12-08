# == Schema Information
#
# Table name: user_symptoms
#
#  id            :bigint           not null, primary key
#  user_id       :bigint
#  symptom_id    :bigint
#  severity      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#  delete_reason :string
#


class UserSymptom < ApplicationRecord
    audited only: :severity
    scope :active, ->  {where(deleted_at: nil)} 
    belongs_to :user
    belongs_to :symptom
    validates :symptom_id, uniqueness: {scope: :user_id, conditions: -> {active}}#,  unless: :deleted?
    has_many :usage_symptom_influences

    
    # def deleted?
    #     deleted_at != nil
    # end

end
