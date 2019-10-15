# == Schema Information
#
# Table name: samples
#
#  id          :bigint           not null, primary key
#  type        :string           not null
#  material_id :integer          not null
#  user_id     :integer
#  device      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Sample < ApplicationRecord
    include Exportable

    belongs_to :material
    belongs_to :user, optional: true
    belongs_to :protocol, optional: true
    belongs_to :brand, optional: true
    belongs_to :hardware, optional: true
    belongs_to :card, optional: true
    has_one :scanner, through: :hardware

    has_many :sample_tags
    has_many :tags, through: :sample_tags

    def data
        raise "no data"
    end

    def file_id
        data.first.file_id
    end

    def files=(val)
        #dummy function to make stuff work
        #do not remove
    end
end
