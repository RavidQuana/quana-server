# == Schema Information
#
# Table name: sampler_types
#
#  id   :bigint           not null, primary key
#  name :string           not null
#

class SamplerType < ApplicationRecord
    has_many :hardwares
end
