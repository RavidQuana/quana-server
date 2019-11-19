# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  birth_date          :datetime         not null
#  requires_local_auth :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  token               :string           not null
#  status              :integer          default("pending"), not null
#  gender              :integer          default("male"), not null
#  last_activity_at    :datetime
#  first_name          :string
#  last_name           :string
#  phone_number        :string           not null
#

class User < ApplicationRecord

    include CodeValidatable

    has_secure_token
    has_many :samples
    has_many :user_symptoms
    has_many :symptoms, through: :user_symptoms
    enum status: {pending_verification: 0, active: 1, suspended: 2}
    enum gender: {male: 0, female: 1, other: 2}

    def should_register
        self.first_name.nil?
    end

end
