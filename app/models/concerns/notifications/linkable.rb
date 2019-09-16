module Notifications
	module Linkable
	  	extend ActiveSupport::Concern

	  	included do
	  		has_many :notifications, as: :linkable, inverse_of: :linkable, dependent: :destroy 
	  	end

	  	# sets the context for the current linkable
	  	# context data will be sent as part of the notification payload
	  	def context
	  		{ }
	  	end
	end
end