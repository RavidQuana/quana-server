# == Schema Information
#
# Table name: users
#
#  id :bigint           not null, primary key
#

class User < ApplicationRecord
    has_many :samples
end
