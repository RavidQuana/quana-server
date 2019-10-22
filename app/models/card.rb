# == Schema Information
#
# Table name: cards
#
#  id   :bigint           not null, primary key
#  name :string           not null
#

class Card < ApplicationRecord
    has_many :samples
end
