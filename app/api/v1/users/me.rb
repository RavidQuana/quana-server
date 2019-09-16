module V1
	module Users
		class Me < Grape::API
			include BaseHelpers
			include UserHelpers

			namespace :me do
				after_validation do
					restrict_access
				end

				#-----[GET]/users/me-----
				# desc "Return the current user's profile",
				#     entity: User::Entity
				# get '/', http_codes: [
				# 	{ code: RESPONSE_CODES[:ok], model: User::Entity },
				# 	{ code: RESPONSE_CODES[:unauthorized], message: 'Invalid or expired user token' }
				# ] do
				# 	render_success @current_user, User::Entity
				# end

				#-----[POST]/users/me-----
				# desc "Update the current user's profile",
				# 	consumes: ['multipart/form-data', 'application/json'],
				#     entity: User::Entity
				# params do
				# 	use :user_attributes
				# 	use :device_attributes
				# end
				# post '/', http_codes: [
				# 	{ code: RESPONSE_CODES[:ok], model: User::Entity },
				# 	{ code: RESPONSE_CODES[:unauthorized], message: 'Invalid or expired user token' },
				# 	{ code: RESPONSE_CODES[:internal_server_error], message: 'Could not update user profile' }
				# ] do
				# 	@current_user.assign_attributes({  }.reject { |k, v| !params.has_key?(k) })
				# 	render_error(RESPONSE_CODES[:internal_server_error], 'Could not update user profile') unless @current_user.save
				# 	attach_device

				# 	@current_user.reload

				# 	render_success @current_user, User::Entity
				# end
			end
		end
	end
end