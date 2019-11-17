# == Schema Information
#
# Table name: symptom_categories
#
#  id   :bigint           not null, primary key
#  name :string           not null
#


class SymptomCategory < ApplicationRecord
    has_many :symptoms
end
