class AdminUtilsController < ApplicationController
  def autocomplete
    params[:resource] = params[:type] if params[:resource] == 'polymorphic'
    autocomplete_resource(params[:resource], params[:term], params[:exact_match], nil)
  end

  private
    def autocomplete_resource(resource, term, exact_match, scope = nil)
      # any param can be checked here and used for custom logic
      # i.e.
      # params[:resource] = params[:o_type] if params[:resource] == 'owner'
      # if params[:resource] == 'street' && params[:city_id].present?
      #     #   scope = ActiveRecord::Base.escape_sql("city_id in (?)", params[:city_id])
      # end

      # where is this?
      # scope = params[:scope].presence
      # TODO: refactor scope usage

      cls = resource.classify.constantize
      results = cls.autocomplete(term, exact_match, scope).limit(Settings.autocomplete_results_count).order(id: :asc)
      render json: {results: results.map(&:autocomplete_item)}, root: false
    end
end