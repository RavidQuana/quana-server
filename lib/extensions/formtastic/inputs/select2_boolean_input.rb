module Formtastic
	module Inputs
		class Select2BooleanInput < Select2Input
			def input_html_options
				super.tap do |options|
					options.deep_merge!({
						data: {
							select2: {
								data: [
									{ id: 'no', text: I18n.t('formtastic.no') }, 
									{ id: 'true', text: I18n.t('formtastic.yes') }
								]
							}
						}
					})
				end
			end   
		end
	end
end