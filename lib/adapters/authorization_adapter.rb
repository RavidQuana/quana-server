class AuthorizationAdapter < ActiveAdmin::AuthorizationAdapter

	def authorized?(action, resource = nil)
		return true if resource.is_a?(ActiveAdmin::Page) && resource.name == 'Dashboard'
		return true if user.has_role?(:administrator)

		resource_name = resource.is_a?(Class) ? resource.name : resource.class.name
		user.admin_role.can? resource_name, action
	end

end