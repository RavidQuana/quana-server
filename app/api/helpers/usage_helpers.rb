module UsageHelpers
  extend ActiveSupport::Concern

  included do
    helpers do

      params :usage_attributes do
        requires  :product_id, type: Integer, allow_blank: false, desc: "The usage product id"

        end
      end

  end
end