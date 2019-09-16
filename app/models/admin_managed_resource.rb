# == Schema Information
#
# Table name: admin_managed_resources
#
#  id         :bigint           not null, primary key
#  class_name :string           not null
#  action     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AdminManagedResource < ApplicationRecord
	include Autocompletable
	autocompletable query_by: ['action', 'class_name'], display_as: '%{display_name}'

	has_many :admin_role_permissions, inverse_of: :admin_managed_resource, dependent: :destroy

	def display_name
		"#{class_name.titleize} | #{action.titleize}"
	end
end
