module UsageHelpers
  extend ActiveSupport::Concern

  included do
    helpers do

      params :usage_attributes do
        requires  :product_id, type: Integer, allow_blank: false, desc: "The usage product id"
        optional  :sample, type: File, allow_blank: false, desc: "The usage binary data"

      end      
      params :usage_symptom_influence_attributes do 
				optional :user_symptom_id, type: Integer, allow_blank: false, desc: "A valid symptom id"
				optional :influence, type: Integer, allow_blank: false, desc: "influance value"
			end

      def get_usage
				@usage = @current_user.usages.find_by(id: params[:usage_id])
				render_error(API::RESPONSE_CODES[:bad_request], 'Invalid usage id') unless @usage.present?
			end
    end
  end
end