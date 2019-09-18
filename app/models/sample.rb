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
    belongs_to :material
    belongs_to :user, optional: true
    has_many :data_points
end
