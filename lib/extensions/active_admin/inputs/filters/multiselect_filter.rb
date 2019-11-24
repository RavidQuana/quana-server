module ActiveAdmin
  	module Inputs
		module Filters
			module MultiselectFilter
				def input_name
					#return super if options[:id].present?
					if options[:not]
						searchable_method_name + '_not_in'
					else 
						searchable_method_name + '_in'
					end
				end

				def searchable_method_name
					if searchable_has_many_through?
						"#{reflection.through_reflection.name}_#{reflection.foreign_key}"
					else
						name = method.to_s
						name.concat "_#{reflection.association_primary_key}" if reflection_searchable?
						name
					end
				end

				def multiple_by_association?
					false
				end
				
				def input_html_options_name
					"#{object_name}[#{input_name}][]"
				end

				def reflection_searchable?
				  reflection && !reflection.polymorphic?
				end  				
			end
		end
	end
end

module ActiveAdmin
	module Filters
	  	module ResourceExtension
			# Add a filter for this resource. If filters are not enabled, this method
			# will raise a RuntimeError
			#
			# @param [Symbol] attribute The attribute to filter on
			# @param [Hash] options The set of options that are passed through to
			#                       ransack for the field definition.
			def add_filterxxx(attribute, options = {})
				raise Disabled unless filters_enabled?
				key = options[:id] || attribute.to_sym
				options[:attribute] = attribute.to_sym
				(@filters ||= {})[key] = options
			end
		end
	end
end