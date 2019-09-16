module ActiveAdmin
  	module Inputs
		module Filters
			module MultiselectFilter
				def input_name
					searchable_method_name + '_in'
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