# == Schema Information
#
# Table name: symptoms
#
#  id                  :bigint           not null, primary key
#  symptom_category_id :bigint
#  name                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#


class Symptom < ApplicationRecord
    belongs_to :symptom_category
    has_many :user_symptoms
end
