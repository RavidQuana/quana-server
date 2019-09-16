class ActiveRecord::Base
  class << self
    def escape_sql(clause, *rest)
      self.send(:sanitize_sql_array, rest.empty? ? clause : ([clause] + rest))
    end   

    def all_polymorphic_types(name)
      @poly_hash ||= {}.tap do |hash|
        Dir.glob(File.join(Rails.root, "app", "models", "**", "*.rb")).each do |file|
          klass = (File.basename(file, ".rb").camelize.constantize rescue nil)
          next if klass.nil? or !klass.ancestors.include?(ActiveRecord::Base)
          klass.reflect_on_all_associations(:has_many).select{|r| r.options[:as] }.each do |reflection|
            (hash[reflection.options[:as]] ||= []) << klass
          end
        end
      end
      @poly_hash[name.to_sym] || []
    end

    def all_types_concerning(name)
      self.descendants.select{ |m| m.included_modules.include?(name) }.map(&:name)
    end
  end
end