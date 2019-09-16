module Formtastic
	module Inputs
		class Select2CheckboxesInput < Select2MultiselectInput
			def input_html_options
				super.tap do |options|
					options.deep_merge!({
						class: 'select2-input s2-checkboxes'
					})
				end
			end   
		end
	end
end