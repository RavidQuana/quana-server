require 'test_helper'

class AdminUsersTest < ActiveSupport::TestCase
	include Rack::Test::Methods

	class CreateAdminUserTest < AdminUsersTest

		setup do
			@new_admin_user = AdminUser.new(
					first_name: 'Oded',
					last_name: 'Shoshan',
					email: 'oded@monkeytech.co.il',
					password: 'Password1',
					admin_role: AdminRole.find_by(name: 'administrator'),
			)
		end

		test "setup data is valid" do
			assert @new_admin_user.valid?
		end

		test "first name required" do
			@new_admin_user.assign_attributes(first_name: nil)
			assert @new_admin_user.invalid?
		end

		test "last name required" do
			@new_admin_user.assign_attributes(last_name: nil)
			assert @new_admin_user.invalid?
		end

		test "simple password is invalid" do
			@new_admin_user.assign_attributes(password: 'password')
			assert @new_admin_user.invalid?
		end

		test "confirmation email is sent on creation" do
			assert_changes 'ActionMailer::Base.deliveries.size' do
				@new_admin_user.save
			end
			mail = ActionMailer::Base.deliveries.last
			confirmation_token = mail.body.to_s[/confirmation_token=([\w-]{20})/, 1]
			assert_equal(confirmation_token, @new_admin_user.confirmation_token)
		end
	end

end
