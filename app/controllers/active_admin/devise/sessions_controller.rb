module ActiveAdmin
	module Devise
		class SessionsController < ::Devise::SessionsController
		  	before_action :authenticate_with_two_factor, only: :create

		  	def authenticate_with_two_factor
				if params[resource_name][:otp_attempt].present? && session[:otp_user_id]
			  		self.resource = resource_class.find_by(id: session[:otp_user_id])
			  		authenticate_with_two_factor_via_otp
				else
					self.resource = resource_class.find_by(email: params[resource_name][:email])
					if resource && resource.otp_required_for_login
						if resource.valid_password?(params[resource_name][:password])
			  				prompt_for_two_factor
			  			end
			  		end
				end
		  	end

		  	def authenticate_with_two_factor_via_otp
				if resource.validate_and_consume_otp!(params[resource_name][:otp_attempt])
				  	warden.authenticate!(:otp_authenticatable)
				  	sign_in(resource_name, resource)
				else
				  	resource.increment_failed_attempts
				  	resource.save
				  
				  	flash.now[:alert] = I18n.t('devise.failure.otp')
				  	prompt_for_two_factor
				end
		  	end

		  	def prompt_for_two_factor	  		
				session[:otp_user_id] = resource.id
				render 'active_admin/devise/sessions/two_factor'
		  	end
		end
	end
end