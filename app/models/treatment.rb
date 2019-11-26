# == Schema Information
#
# Table name: treatments
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Treatment < ApplicationRecord
    has_many :user_treatments


end