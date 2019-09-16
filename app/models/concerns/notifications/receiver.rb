module Notifications
	module Receiver
		extend ActiveSupport::Concern

	  	included do
			has_many :received_notifications, inverse_of: :receiver, as: :receiver, 
				class_name: 'Notification', dependent: :destroy
	  	end 

	  	# toggles notification delivery for the current receiver
	  	def allow_notifications?(notification_type)
	  		true
	  	end 
	end
end