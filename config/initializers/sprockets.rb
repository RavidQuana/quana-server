require 'sprockets'

Sprockets::DirectiveProcessor.class_eval do
  def process_depend_on_file_directive(file)
    uri, deps = @environment.resolve!(file, load_paths: [::Rails.root.to_s])
    @dependencies.merge(deps)
    uri
  end
end