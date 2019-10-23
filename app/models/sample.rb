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
#  material    :string           default("Material"), not null
#  fan_speed   :integer          default(0), not null
#  product_id  :integer          not null
#

class Sample < ApplicationRecord
    include Exportable

    belongs_to :user, optional: true
    belongs_to :protocol
    belongs_to :product
    belongs_to :sampler
    belongs_to :card
    has_one :sampler_type, through: :sampler
    has_one :brand, through: :product

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
