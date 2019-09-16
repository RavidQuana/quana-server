module Notifications
	module Sender
		extend ActiveSupport::Concern

	  	included do
	  		has_many :sent_notifications, inverse_of: :sender, as: :sender, 
	  			class_name: 'Notification', dependent: :destroy
	  	end 
	end
end