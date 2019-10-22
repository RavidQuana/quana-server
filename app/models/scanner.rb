# == Schema Information
#
# Table name: scanners
#
#  id   :bigint           not null, primary key
#  name :string           not null
#

class Scanner < ApplicationRecord
    has_many :hardwares
end
