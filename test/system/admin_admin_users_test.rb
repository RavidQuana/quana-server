require 'application_system_test_case'

class AdminAdminUsersTest < ApplicationSystemTestCase
	include Rack::Test::Methods # make 'header' method from helper known in this context
	include Devise::Test::IntegrationHelpers # use devise sign_in helper in setup

	def setup
		@admin_user = admin_users(:administrator)
		sign_in @admin_user
	end


	class AdminUserPagesLoad < AdminAdminUsersTest
		test "visiting index" do
			visit admin_admin_users_path
			assert_selector 'h2', text: I18n.t('activerecord.models.admin_user.other')
		end
		test "visiting create" do
			visit new_admin_admin_user_path
			assert_selector 'span.breadcrumb', text: I18n.t('activerecord.models.admin_user.other')
		end
		test "visiting edit" do
			visit edit_admin_admin_user_path(@admin_user)
			assert_selector 'span.breadcrumb', text: I18n.t('activerecord.models.admin_user.other')
		end
		test "visiting read" do
			visit admin_admin_user_path(@admin_user)
			assert_selector 'span.breadcrumb', text: @admin_user.name
		end
	end

	class AdminUserCreate < AdminAdminUsersTest

		test "creates new admin user" do
			visit new_admin_admin_user_path

			fill_in 'admin_user_first_name', with: 'Oded'
			fill_in 'admin_user_last_name', with: 'Shoshan'
			fill_in 'admin_user_email', with: 'oded@monkeytech.co.il'
			fill_in 'admin_user_password', with: 'Password1'
			fill_in 'admin_user_password_confirmation', with: 'Password1'
			select2(AdminRole.first.display_name, from: 'admin_user_admin_role_id')
			click_on 'אישור'

			assert_selector 'h2', text: 'Oded Shoshan'
		end
	end
end