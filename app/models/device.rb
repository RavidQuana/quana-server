# == Schema Information
#
# Table name: devices
#
#  id              :bigint           not null, primary key
#  owner_id        :integer
#  owner_type      :string
#  device_token    :string
#  os_type         :integer
#  device_type     :string
#  os_version      :string
#  app_version     :string
#  failed_attempts :integer          default(0)
#  is_sandbox      :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Device < ApplicationRecord
	include ExportFields

	belongs_to :owner, polymorphic: true

	enum os_type: { ios: 0, android: 1 }

	scope :active, -> { where('failed_attempts <= ?', Settings.max_device_failed_attempts) }

	validates :device_token, presence: true, uniqueness: { scope: :os_type }
	validates :os_type, presence: true
	validates :is_sandbox, inclusion: { in: [true, false] }	
end
