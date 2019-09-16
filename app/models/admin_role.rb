# == Schema Information
#
# Table name: admin_roles
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class AdminRole < ApplicationRecord
	include Autocompletable
	autocompletable query_by: ['name', 'display_name'], display_as: '%{display_name}'

	has_many :admin_users, foreign_key: :role_id, inverse_of: :admin_role, dependent: :nullify
	has_many :admin_role_permissions, inverse_of: :admin_role, dependent: :destroy
	has_many :admin_managed_resources, through: :admin_role_permissions
	accepts_nested_attributes_for :admin_role_permissions, allow_destroy: true

	validates :name, :display_name, presence: true

	def can?(resource, action)
		admin_managed_resources.where(class_name: resource, action: action).exists?
	end
end
