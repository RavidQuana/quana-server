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
            format.csv { 
                # Tell Rack to stream the content
                headers.delete("Content-Length")
                # Don't cache anything from this generated endpoint
                headers["Cache-Control"] = "no-cache"
                # Tell the browser this is a CSV file
                headers["Content-Type"] = "text/csv"
                # Make the file download with a specific filename
                headers["Content-Disposition"] = "attachment; filename=\"example.csv\""
                # Don't buffer when going through proxy servers
                headers["X-Accel-Buffering"] = "no"
                # Set an Enumerator as the body
                self.response_body = resource.stream_csv_report(collection)
                # Set the status to success
                response.status = 200
                #stream_csv
            }
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