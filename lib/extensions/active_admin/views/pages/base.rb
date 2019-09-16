module ActiveAdmin
	module Views
		module Pages
			class Base < Arbre::HTML::Document
				def build(*args)
					super
					set_attribute :lang, I18n.locale
          			build_active_admin_head
          			build_page
				end
			end
		end 
	end
end