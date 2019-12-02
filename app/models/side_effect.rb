# == Schema Information
#
# Table name: side_effects
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SideEffect < ApplicationRecord
    has_many :usage_side_effects


end
