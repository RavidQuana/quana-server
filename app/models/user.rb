# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  user_name           :string           not null
#  phone_number        :string           not null
#  birth_date          :datetime         not null
#  requires_local_auth :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class User < ApplicationRecord
    has_many :samples
end
