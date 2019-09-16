module Formtastic
	module Inputs
		class MultilingualTextInput < StringInput
			def to_html
				inputs = []
				original_method = method

				locales = options[:only].presence || ::I18n.available_locales
				locales.reject! { |l| options[:except].include?(l) } if options[:except].present?

				locales.each do |locale|
					self.method = "#{original_method}_#{locale}".to_sym
					
					inputs << input_wrapping do
            			label_html <<
            			builder.text_field(method, input_html_options)
          			end
				end

				inputs.reduce(&:+)
	        end   
		end
	end
end