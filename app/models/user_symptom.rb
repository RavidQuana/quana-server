# == Schema Information
#
# Table name: user_symptoms
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  symptom_id :bigint
#  severity   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class UserSymptom < ApplicationRecord
    audited only: :severity
    belongs_to :user
    belongs_to :symptom
    has_many :usage_symptom_influences
end
