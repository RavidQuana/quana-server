# == Schema Information
#
# Table name: notification_types
#
#  id               :bigint           not null, primary key
#  name             :string
#  body_pattern     :jsonb
#  client_action_id :integer
#  send_push        :boolean          default(FALSE)
#  send_sms         :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class NotificationType < ApplicationRecord
	include Autocompletable
	autocompletable query_by: ['lower(name)'], display_as: "%{name}"

	extend Mobility
	translates :body_pattern, fallthrough_accessors: true

	belongs_to :client_action
	has_many :notifications, dependent: :destroy

	delegate :required_linkable_type, to: :client_action, allow_nil: true
	delegate :name, to: :client_action, prefix: :client_action, allow_nil: true

end
