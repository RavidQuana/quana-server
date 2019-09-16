module ApplicationHelper
	def phonelib_phone(phone, cc=nil)
    	Phonelib.parse(phone, cc || Settings.default_country_code)		
	end

  	def international_phone_number(phone, cc=nil)
    	phonelib_phone(phone, cc).international if phone.present?
  	end

  	def national_phone_number(phone, cc=nil)
    	phonelib_phone(phone, cc).national if phone.present?
    end

    def i18n_resource_key(resource)
    	resource.name.underscore
    end

  	def humanized_resource(resource)
    	I18n.t("activerecord.models.#{i18n_resource_key(resource)}.one")
  	end

  	def humanized_resources(resource)
  		I18n.t("activerecord.models.#{i18n_resource_key(resource)}.other")
  	end

	def humanized_attribute(resource, attribute)
		I18n.t("activerecord.attributes.#{i18n_resource_key(resource)}.#{attribute.underscore}")
	end

	def humanized_enum_value(resource, enum, v)
		humanized_attribute(resource, "#{enum.to_s.pluralize}.#{v}")
	end

	def attribute_select(resource)
		Hash[resource.column_names.map { |col| [I18n.t("activerecord.attributes.#{resource.name.underscore}.#{col}"), col] }]
	end

	def sanitized_html(content)
		sanitize(content, tags: ['div', 'span', 'strong', 'b', 'u', 'i', 'ul', 'ol', 'li', 'a']).html_safe if content.present?
	end

	def color_tag(color, options={})
		content_tag :div, nil, class: 'color-tag', style: "background-color: #{color};", **options
	end

	def pad_with_zeros(v, n)
		v.to_s.rjust(n, '0')
	end

	def year_select(starts_at=1920)
	    starts_at..Time.zone.now.year
	end

	def month_select
	    1..12
	end	

	def time_select(step=5)
		collection = []

		(0..23).each do |h|
			(0..59).step(step).each do |m|
				collection << "#{pad_with_zeros(h, 2)}:#{pad_with_zeros(m, 2)}"
			end
		end

		collection
	end

  	def errors_block(obj)
    	obj.errors.full_messages.map { |e| content_tag(:div, e) }.reduce(&:+)
  	end

	def range(min, max)
		max.present? ? "#{min}-#{max}" : "#{min}+"
	end

	def meta_tags(collection=[], attribute=nil, options={})
		link_type = options[:link_type] || :none
		classes = "meta-tag #{options[:class]}"
		formatter = options[:formatter] || ->(v) { v }
		opts = options.except(:link_type, :class, :formatter)

		collection.map { |el| 
			v = el.send(attribute)
			v = formatter.call(v) if formatter.respond_to?(:call)
			
			case link_type
			when :admin_resource
				link_to(content_tag(:span, v), polymorphic_path([:admin, el]), class: classes, **opts)
			when :standard_resource
				link_to(content_tag(:span, v), polymorphic_path(el), class: classes, **opts)
			when :none
				content_tag(:div, v, class: classes, **opts)
			end
		}.reduce(&:+)
	end

	def meta_tag(obj, attribute, options={})
		meta_tags [obj], attribute, options unless obj.blank?
	end

	def boolean_tag(obj, attribute, options={})
		meta_tag obj, attribute, options.merge({ formatter: ->(v) { 
			v ? I18n.t('formtastic.yes') : I18n.t('formtastic.no') } })
	end

	def enum_tag(obj, attribute, options={})
		meta_tag obj, attribute, options.merge({ formatter: ->(v) { 
			humanized_enum_value(obj.class, attribute, v) } })
	end

	def image_thumbs(collection=[], options={})
		collection.map { |src|
			content_tag(
				:div,
				image_tag(
					src,
					data: { lightbox: 'image' }
				),
				class: 'image-tag',
				**options
			)
		}.reduce(&:+)
	end

	def image_thumb(src, options={})
		image_thumbs [src], options unless src.blank?
	end

	def polymorphic_type_select(resource, association)
		types = resource.all_polymorphic_types(association)
		Hash[types.map { |resource| [humanized_resource(resource), resource.name] }]
	end

	def enum_value_select(resource, enum)
		enum_key = enum.to_s

		return unless resource.defined_enums.has_key?(enum_key)

		enum_hash = resource.send(enum_key.pluralize)
		Hash[enum_hash.map { |k, v| [humanized_enum_value(resource, enum, k), k] }]
	end

	def reading_direction
		[:he, :ar].include?(I18n.locale) ? 'rtl' : 'ltr'
	end

	def default_text_alignment
		[:he, :ar].include?(I18n.locale) ? 'right' : 'left'
	end
end