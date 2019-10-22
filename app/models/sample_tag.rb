# == Schema Information
#
# Table name: sample_tags
#
#  id        :bigint           not null, primary key
#  sample_id :integer          not null
#  tag_id    :integer          not null
#

class SampleTag < ApplicationRecord
    belongs_to :sample
    belongs_to :tag
end
