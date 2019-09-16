module Formtastic
	module Inputs
		class Select2MultiselectInput < Select2Input
			def input_options
				super.tap do |options|
					options.merge!({
						include_blank: false
					})
				end
			end			

			def input_html_options
				super.tap do |options|
					options.deep_merge!({
						multiple: true,
						data: {
							select2: {
								allowClear: false
							}
						}
					})
				end
			end   
		end
	end
end