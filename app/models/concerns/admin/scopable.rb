module Admin
  module Scopable
    extend ActiveSupport::Concern

    def self.included(base)
      resource = base.config.resource_class.name.constantize
      resource_name = resource.name.singularize.underscore

      is_restorable = resource.table_exists? ? resource.column_names.include?('deleted_at') : false
      options = base.instance_values['config'].instance_variable_get(:@options)

      base.send(:scope, -> {I18n.t('active_admin.scopes.all')}, :all, default: true)

      enums = resource.defined_enums.select {|name, h| (options[:scopes].try(:keys) || []).include?(name.to_sym)}

      if enums.any?
        enums.each do |name, h|
          h.each do |k, v|
            base.send(:scope, -> {I18n.t("activerecord.attributes.#{resource_name}.#{options[:scopes][name.to_sym]}_#{k}")}, k) do |scope|
              if is_restorable
                # explicitly include the 'deleted_at IS NULL' statement to fix a bug with activeadmin's scope counters
                scope.where("#{resource_name.pluralize}.deleted_at is null").send(k)
              else
                scope.send(k)
              end
            end
          end
        end
      end
    end
  end
end

