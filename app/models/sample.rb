# == Schema Information
#
# Table name: samples
#
#  id          :bigint           not null, primary key
#  type        :string           not null
#  user_id     :integer
#  device      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  file_name   :string           default(""), not null
#  protocol_id :integer
#  brand_id    :integer
#  hardware_id :integer
#  card_id     :integer
#  note        :string
#  repetition  :integer          default(0), not null
#  material    :string           default("Material"), not null
#

class Sample < ApplicationRecord
    include Exportable

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
