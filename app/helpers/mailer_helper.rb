module MailerHelper
	def to_css_string(style)
		style.map { |property, value| "#{property.to_s.dasherize}: #{value}" }.join(';')
	end
end