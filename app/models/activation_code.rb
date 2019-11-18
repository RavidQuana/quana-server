# == Schema Information
#
# Table name: activation_codes
#
#  id          :bigint           not null, primary key
#  owner_id    :integer          not null
#  owner_type  :string           not null
#  code        :string           not null
#  tries_count :integer          default(0), not null
#  expires_at  :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ActivationCode < ApplicationRecord
	belongs_to :owner, polymorphic: true

	validates :code, presence: true
	validates :tries_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0,
		less_than_or_equal_to: Settings.max_tries_count }	

	scope :active, -> { where('tries_count < ? AND expires_at > ?', Settings.max_tries_count, Time.current) }
end
