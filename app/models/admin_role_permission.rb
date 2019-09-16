# == Schema Information
#
# Table name: admin_role_permissions
#
#  id                        :bigint           not null, primary key
#  admin_role_id             :integer          not null
#  admin_managed_resource_id :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class AdminRolePermission < ApplicationRecord
	belongs_to :admin_role
	belongs_to :admin_managed_resource

	attr_writer :class_name

	delegate :class_name, to: :admin_managed_resource, allow_nil: true
end
