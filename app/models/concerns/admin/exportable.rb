module Admin
  module Exportable
    extend ActiveSupport::Concern

    def self.included(base)
      resource = base.config.resource_class.name.constantize
      resource_name = resource.name.singularize.underscore

      # patch index action
      base.send(:controller) do
        send(:before_action, only: :index) do |controller|
          if controller.request.format.html?
            @per_page = params[:pagination] unless params[:pagination].blank?
          else
            @per_page = resource.count
          end
        end

        send(:define_method, :index) do
          index! do |format|
            format.csv { stream_csv }
            format.xlsx {
              filters = @search.conditions.map {
                  |condition| ActiveAdmin::Filters::ActiveFilter.new(base.config, condition.dup)
              }
              filter_data = filters.map {|filter| {
                  key: filter.label,
                  value: filter.values.map {|v| v.try(:id) || v}.join(', ')
              }}

              DataExporter.perform_async(@current_admin_user.email, resource_name, collection.map(&:id),
                                         collection.includes_values, filter_data)
              flash[:notice] = I18n.t('active_admin.data_export.success', email: @current_admin_user.email)
              redirect_to request.referer
            }
          end
        end
      end
    end
  end
end