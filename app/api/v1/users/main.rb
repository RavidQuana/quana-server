module V1
  	module Users
    	class Main < Grape::API
      		include BaseHelpers
      		mount V1::Users::Authentication

      		resource :users do
        		mount V1::Users::Me
      		end
    	end
  	end
end