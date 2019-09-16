# create a simple warden strategy to use following the validations in the above controller
# this is needed in order to trigger external callbacks (such as the ones added by devise-security)
# unfortunately, we can't really use the standard two_factor_authenticatable strategy since it relies 
# on all authentication params (email, password & otp) to be present at the same time 
module Devise
	module Strategies
		class OtpAuthenticatable < Authenticatable
			def valid?
				session[:otp_user_id]
			end

			def authenticate!
				resource = mapping.to.find_by(id: session[:otp_user_id])

				if validate(resource){ true }
					session.delete(:otp_user_id)

					remember_me(resource)
					resource.after_database_authentication
					success!(resource)
				end
			end
		end
	end
end

Warden::Strategies.add(:otp_authenticatable, Devise::Strategies::OtpAuthenticatable)