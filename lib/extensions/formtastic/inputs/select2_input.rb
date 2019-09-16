module Formtastic
	module Inputs
		class Select2Input < SelectInput
			def input_html_options
				super.tap do |options|
					options.deep_merge!({
						class: 'select2-input',
						data: {
							select2: {
								width: 'resolve',
								allowClear: true,
								dir: [:he, :ar].include?(::I18n.locale) ? 'rtl' : 'ltr',
								language: ::I18n.locale,
								placeholder: ::I18n.t('active_admin.any')
							}
						}
					})
				end
			end   
		end
	end
end