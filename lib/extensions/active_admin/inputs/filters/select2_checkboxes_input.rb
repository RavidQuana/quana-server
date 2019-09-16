module ActiveAdmin
  	module Inputs
		module Filters
	  		class Select2CheckboxesInput < ::Formtastic::Inputs::Select2CheckboxesInput
				include Base
				include MultiselectFilter
	  		end
		end
  	end
end