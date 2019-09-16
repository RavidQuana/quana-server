module Admin
  module Restorable
    extend ActiveSupport::Concern

    def self.included(base)
      resource = base.config.resource_class.name.constantize
      klass = base.config.resource_class

      base.send(:member_action, :restore, :method => :get) do
        item = klass.find(params[:id])
        item.active!
        redirect_to collection_path
      end

      base.send(:member_action, :delete, :method => :get) do
        item = klass.find(params[:id])
        item.deleted!
        redirect_to collection_path
      end
    end


  end
end
