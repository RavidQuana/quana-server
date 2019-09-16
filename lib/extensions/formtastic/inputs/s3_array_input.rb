module Formtastic
	module Inputs
		class S3ArrayInput < S3FileInput
			def input_html_options
				super.tap do |options|
					options[:multiple] = true
				end
			end

			def to_html
				s3_file_keys = @object.send("#{method}_keys")
			  	s3_file_urls = @object.send("#{method}_urls")
			  	
				input_wrapping do
				  	label_html <<
				  	template.hidden_field_tag("#{object_name}[#{method}_keys]", s3_file_keys, class: 's3-file-keys') <<
				  	template.content_tag(:div, builder.file_field(method, input_html_options), class: 's3-input-wrapper') <<
				  	s3_file_urls.map { |url| s3_file_preview(url.split('/').last,url) }.reduce(&:+)
				end
			end
		end
	end
end