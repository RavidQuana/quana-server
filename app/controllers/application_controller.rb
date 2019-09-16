class ApplicationController < ActionController::Base
	before_action :force_two_factor_authentication

	protected

		def force_two_factor_authentication
			if two_factor_required? and current_admin_user.present? and !current_admin_user.otp_required_for_login
				redirect_to otp_setup_path and return unless params[:controller] == 'active_admin/devise/otp'
			end
		end

		# force the above behavior after login
		def after_sign_in_path_for(user)
			otp_setup_path if two_factor_required? and !user.otp_required_for_login
			request.env['omniauth.origin'] || stored_location_for(user) || root_path
		end

	private

		def two_factor_required?
			Rails.configuration.two_factor.enabled.include? Rails.env.to_sym
		end

end