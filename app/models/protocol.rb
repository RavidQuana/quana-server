# == Schema Information
#
# Table name: protocols
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  description :string           not null
#

class Protocol < ApplicationRecord
    has_many :samples
end
