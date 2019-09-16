module Admin
  module Editable
    extend ActiveSupport::Concern
  end
end

module ActiveAdmin
  module Views
    class IndexAsTable
      class IndexTableFor
        def editable_column(field, opts = {})
          if authorized? :edit, resource_class
            column(field, ->(instance) {
              # patch for select2 in-place editing
              # build collection based on current item and bip format
              if opts[:inner_class] == 'select2-input'
                field_name = field.to_s

                if field_name.include?('_id')
                  # remove _id from field name
                  field_without_id = field_name.split('_id').first
                  opts[:collection] = instance.send(field_without_id).try(:bip_item) || []
                else
                  current_collection = opts[:collection].clone
                end
              end
              resource_name = instance.class.name.underscore.downcase
              best_in_place instance, field, opts.merge({
                                                            url: send("admin_#{resource_name}_path", id: instance.id, locale: I18n.locale)
                                                        })
            })
          else
            column(field, ->(instance) {
              if field.to_s.include?('id')
                obj = instance.send(field.to_s.gsub('_id', ''))
                obj.try(:display_name) || obj.try(:full_name) || obj.try(:name)
              else
                instance.send(field)
              end
            })
          end
        end
      end
    end
  end
end 