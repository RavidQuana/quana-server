require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Archicebus
	class Application < Rails::Application
		# Initialize configuration defaults for originally generated Rails version.
		config.load_defaults 5.2

		# set server encoding
		config.encoding = 'utf-8'
		config.i18n.default_locale = :he
		config.i18n.fallbacks = false
		config.i18n.available_locales = [:he, :en]

		# set server timezone
		config.time_zone = 'Asia/Jerusalem'

		# grape api configuration
		config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
		config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

		# auto-load lib folder
		config.autoload_paths += %W(#{config.root}/lib)
		config.eager_load_paths += %W(#{config.root}/lib)

		# auto-load active admin's controllers (used for overrides)
		config.autoload_paths += %W(#{config.root}/controllers/active_admin)

		# additional assets
		config.assets.precompile += %w( swagger.css swagger.js )

		# override default devise mailer layout
		config.to_prepare {
			Devise::Mailer.layout 'mailer'
			Devise::Mailer.helper :application, :mailer
		}

    	# enable 2fa for selected environments
    	config.two_factor = ActiveSupport::OrderedOptions.new
    	config.two_factor.enabled = []
    	
		# don't log 2fa otps
		Rails.application.config.filter_parameters += [:otp_attempt]

		# use rack::attack
		config.middleware.use Rack::Attack

		config.middleware.insert_before 0, Rack::Cors do
			allow do
				origins 'localhost:3000', '127.0.0.1:3000'
				resource '*', headers: :any,
					methods: [:get, :post, :options, :delete],
					expose: ['Access-Token', 'x-page', 'x-per-page', 'x-next-page', 'x-total-pages', 'x-total']
			end
		end

		# monkeypatch the credentials method to support multi-environment credentials
		def credentials
			if Rails.env.production?
				super
			else
				encrypted(
					"config/credentials.#{Rails.env.downcase}.yml.enc",
					key_path: "config/#{Rails.env.downcase}.key"
				)
			end
		end
	end
end
