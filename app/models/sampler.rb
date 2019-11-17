# == Schema Information
#
# Table name: samplers
#
#  id              :bigint           not null, primary key
#  sampler_type_id :integer          not null
#  name            :string           not null
#

class Sampler < ApplicationRecord
    include Autocompletable
    autocompletable query_by: ['samplers.name', 'sampler_types.name'], display_as: "%{to_s}", joins: [:sampler_type]

    belongs_to :sampler_type

    def to_s
        "#{self.sampler_type.name} #{self.name}"
    end

end
