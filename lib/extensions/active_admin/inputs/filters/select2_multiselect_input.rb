module ActiveAdmin
  	module Inputs
    	module Filters
      		class Select2MultiselectInput < ::Formtastic::Inputs::Select2MultiselectInput
				include Base
				include MultiselectFilter     			
      		end
    	end
  	end
end