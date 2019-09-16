module Admin
  module Translatable
    extend ActiveSupport::Concern

    def self.included(base)
      resource = base.config.resource_class.name.constantize
      resource_name = resource.name.singularize.underscore

      base.config.send(:clear_action_items!)

      base.send(:action_item, :new, {only: :index}) do
        begin
          link_to I18n.t('active_admin.new_model', model: resource.model_name.human), send("new_admin_#{resource_name}_path", locale: I18n.locale)
        rescue => e
          # the translated model doesn't support the 'new' action
        end
      end

      # patch redirects following basic actions
      base.send(:controller) do
        send(:define_method, :create) do |*args|
          super(*args) do |success, failure|
            success.html {redirect_to collection_url(locale: I18n.locale) and return}
            failure.html do
              instance = instance_variable_get("@#{resource.name.underscore.downcase}")
              flash.now[:error] = instance.errors.full_messages.join(', ')
              render :new
            end
          end
        end

        send(:define_method, :update) do |*args|
          update!(*args) do |success, failure|
            success.html {redirect_to collection_url(locale: I18n.locale) and return}
            failure.html do
              instance = instance_variable_get("@#{resource.name.underscore.downcase}")
              flash.now[:error] = instance.errors.full_messages.join(', ')
              render :edit
            end
          end
        end

        send(:define_method, :destroy) do |*args|
          super(*args) do |success, failure|
            success.html do
              if params[:referrer].present?
                redirect_to params[:referrer] and return
              else
                redirect_to collection_url(locale: I18n.locale) and return
              end
            end
            failure.html do
              instance = instance_variable_get("@#{resource.name.underscore.downcase}")
              flash.now[:error] = instance.errors.full_messages.join(', ')
              redirect_to :back
            end
          end
        end
      end
    end
  end
end

module ActiveAdmin
  module ViewHelpers
    module AutoLinkHelper
      def auto_url_for(resource)
        config = active_admin_resource_for(resource.class)
        return unless config

        if config.controller.action_methods.include?("show") &&
            authorized?(ActiveAdmin::Auth::READ, resource)
          url_for config.route_instance_path(resource).gsub('/he/', "/#{I18n.locale}/")
        elsif config.controller.action_methods.include?("edit") &&
            authorized?(ActiveAdmin::Auth::UPDATE, resource)
          url_for config.route_edit_instance_path(resource).gsub('/he/', "/#{I18n.locale}/")
        end
      end
    end
  end
end

module ActiveAdmin
  module Filters
    class Humanized
      def initialize(param, resource = nil)
        @body = param[0]
        @value = param[1]
        @resource = resource
      end

      private

      def parse_parameter_body
        return if current_predicate.nil?

        # Accounting for strings that might contain other predicates. Example:
        # 'requires_approval' contains the substring 'eq'
        split_string = "_#{current_predicate}"

        b = @body.split(split_string)
                .first
                .strip

        # Translate Body
        I18n.t("activerecord.attributes.#{@resource}.#{b}")
      end
    end
  end
end