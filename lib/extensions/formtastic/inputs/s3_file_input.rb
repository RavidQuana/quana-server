module Formtastic
	module Inputs
		class S3FileInput < FileInput
			def input_html_options
				s3_post = @object.class.s3_presigned_post
				s3_options = s3_post.fields.merge({ url: s3_post.url })
				super.tap do |options|
					options.merge!({ data: s3_options })
				end
			end

			def to_html
				s3_file_key = @object.send("#{method}_key")
			  	s3_file_url = @object.send("#{method}_url")
			  	
				input_wrapping do
				  	label_html <<
				  	template.hidden_field_tag("#{object_name}[#{method}_key]", s3_file_key, class: 's3-file-keys') <<
				  	template.content_tag(:div, builder.file_field(method, input_html_options), class: 's3-input-wrapper') <<
				  	s3_file_preview(s3_file_key, s3_file_url)
				end
			end

			private
				def s3_file_preview(key, url)
					return nil if key.blank? || url.blank?

					template.content_tag(
			  			:div, 
			  			template.content_tag(:div, nil, class: 's3-clear', data: { key: key }) +
			  			s3_file_thumb(key, url),
			  			class: 's3-file-preview'
			  		)					
				end

				def s3_file_thumb(key, url)
					content_type = MIME::Types.type_for(url).first&.content_type
				  	
				  	case content_type
				  	when /image/
				  		template.image_tag url, class: 's3-thumb'
				  	when /video/
				  		template.video_tag url, class: 's3-thumb'
				  	else
				  		template.content_tag :div, key, class: 's3-thumb no-preview'
				  	end					
				end
		end
	end
end