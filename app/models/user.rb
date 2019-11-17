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
#  token               :string           not null
#  status              :integer          default("pending"), not null
#  gender              :integer          default("male"), not null
#  last_activity_at    :datetime
#

class User < ApplicationRecord
    has_secure_token
    has_many :samples
    enum status: {pending: 0, active: 1, suspended: 2}
    enum gender: {male: 0, female: 1, other: 2}
end
