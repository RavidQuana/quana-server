require "grape-swagger"

module V1
	class Main < Grape::API
		version 'v1', using: :path, vendor: Settings.project_name.underscore

		mount V1::Users::Main
		mount V1::Utils::Main

		unless Rails.env.production?
			add_swagger_documentation \
				host: Settings.server_domain,
				mount_path: '/docs',
				base_path: '/api/v1',
				api_version: 'v1',
				format: :json,
				add_version: false,
				hide_documentation_path: true,
				info: {
					title: "#{Settings.project_name} API"
				},
				security_definitions: {
					token: {
						type: "apiKey",
						name: "X-Auth-Token",
						in: "header"
					}
				},
				security: [
					{ token: [] }
				],
				tags: [
					{ name: 'auth', description: 'Authentication related endpoints' },
        			{ name: 'utils', description: 'General utility endpoints' }
      			]
		end
	end
end