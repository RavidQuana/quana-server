# == Schema Information
#
# Table name: admin_users
#
#  id                        :bigint           not null, primary key
#  first_name                :string           not null
#  last_name                 :string           not null
#  thumbnail                 :string
#  admin_role_id             :integer
#  email                     :string           default(""), not null
#  encrypted_password        :string           default(""), not null
#  reset_password_token      :string
#  reset_password_sent_at    :datetime
#  sign_in_count             :integer          default(0), not null
#  current_sign_in_at        :datetime
#  last_sign_in_at           :datetime
#  current_sign_in_ip        :inet
#  last_sign_in_ip           :inet
#  confirmation_token        :string
#  confirmed_at              :datetime
#  confirmation_sent_at      :datetime
#  unconfirmed_email         :string
#  failed_attempts           :integer          default(0), not null
#  unlock_token              :string
#  locked_at                 :datetime
#  password_changed_at       :datetime
#  unique_session_id         :string(20)
#  last_activity_at          :datetime
#  expired_at                :datetime
#  encrypted_otp_secret      :string
#  encrypted_otp_secret_iv   :string
#  encrypted_otp_secret_salt :string
#  consumed_timestep         :integer
#  otp_required_for_login    :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class AdminUser < ApplicationRecord
	include ExportFields
	include Autocompletable
	autocompletable query_by: ['email'], display_as: "%{email}"

  	include Autocompletable
  	autocompletable query_by: ['email'], display_as: "%{email}"

  	include Uploadable
  	mount_field :thumbnail

	devise :two_factor_authenticatable, :confirmable, :recoverable, :lockable, :secure_validatable, 
		:timeoutable, :trackable, #:password_expirable, 
		:password_archivable, #:session_limitable, #:expirable, 
		otp_secret_encryption_key: Rails.application.credentials.opt_encryption_key

	belongs_to :admin_role

	validates :first_name, :last_name, :admin_role, presence: true

	delegate :name, to: :admin_role, prefix: :role, allow_nil: true

	def name
		"#{first_name} #{last_name}"
	end

	def name=(value)
		self.first_name, self.last_name = value.split(' ', 2)
	end

	def has_role?(role)
		role_name == role.to_s
	end
end
