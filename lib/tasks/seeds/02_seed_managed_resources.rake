namespace :db do
	namespace :seed do
		desc "Seed default managed resources"
		task managed_resources: :environment do
			AdminManagedResource.destroy_all
			ActiveRecord::Base.connection.reset_pk_sequence!(:admin_managed_resources)

			skip_resources = ['ActiveAdmin::Comment']
			namespace = ActiveAdmin.application.namespace(:admin)
			resources, pages = namespace.resources.partition { |r| r.respond_to? :resource_class }

			resource_actions =
					resources.each_with_object({}) do |resource, actions|
						resource_name = resource.resource_class.name

						unless skip_resources.include? resource_name
							actions[resource_name] = [:read, :create, :update, :destroy]
							actions[resource_name].concat resource.member_actions.map { |action| action.name }
							actions[resource_name].concat resource.collection_actions.map { |action| action.name }
						end
					end

			resource_actions.each do |resource, actions|
				actions.each do |action|
					AdminManagedResource.create(class_name: resource, action: action)
				end
			end

			pages.each do |page|
				AdminManagedResource.create(class_name: page.name, action: :read)
			end

			AdminRole.destroy_all
			ActiveRecord::Base.connection.reset_pk_sequence!(:admin_roles)

			role = AdminRole.create(name: 'administrator', display_name: 'מנהל מערכת')
			role.admin_managed_resources = AdminManagedResource.all
			role.save
		end
	end
end