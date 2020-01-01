source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.4'

gem 'rails', '6.0.0'
gem 'sprockets', '>= 3.7.2'

# use postgres as the database for ActiveRecord
gem 'pg'

# use SASS and bootstrap for stylesheets
gem 'sass'
gem 'sassc-rails'
gem 'bootstrap-sass'

# use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# add jquery support
gem 'jquery-rails'

# turbolinks makes following links in your web application faster
gem 'turbolinks'
gem 'jquery-turbolinks'

# reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development do
  gem 'spring'
  gem 'annotate'
  gem 'letter_opener'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'bundler-audit' # check for vulnerabilities with '$ bundle audit check --update'
  gem 'brakeman' # check for security issues with '$ brakeman'
end

# use puma as the application server
gem 'puma', '>= 4.3.1'

# utils
gem 'rqrcode'
gem 'mobility'
gem 'money-rails'
gem 'require_all'
gem 'rack-attack'
gem 'rest-client'
gem 'select2-rails'
gem 'settingslogic'
gem 'best_in_place'
gem 'underscore-rails'
gem 'strip_attributes'
gem 'devise-two-factor'
gem 'rack-cors', '>= 1.0.4', require: 'rack/cors'
gem 'active_admin_datetimepicker', github: 'activeadmin-plugins/active_admin_datetimepicker'

# use the ActiveAdmin interface
gem 'inherited_resources'
gem 'activeadmin'
gem 'arctic_admin'
gem 'devise'
gem 'devise-security'

# use the aws s3 sdk for direct file uploads
gem 'aws-sdk-s3'

# s3-file-input is based on jquery-fileupload
gem 'jquery-fileupload-rails'

# use Grape for the api server
gem 'grape'
gem 'grape-entity'
gem 'grape-swagger'
gem 'grape-swagger-entity'
gem 'grape-kaminari', github: 'joshmn/grape-kaminari'

# excel export
gem 'axlsx', '3.0.0.pre'
gem 'axlsx_rails'

# bug tracking
gem 'bugsnag'

# use sidekiq for handling background jobs
gem 'clockwork'
gem 'daemons'
gem 'sidekiq'
gem 'redis'
gem 'redis-rails'
gem 'sinatra', require: false

# sms
gem 'phonelib'
gem 'twilio-ruby'

# push notifications
gem 'fcm'
gem 'houston'

gem 'solargraph', group: :development

group :test do
  gem 'bundler-audit' # check for vulnerabilities with '$ bundle audit check --update'
  gem 'brakeman' # check for security issues with '$ brakeman'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers', '~> 4.0'
  gem 'minitest-reporters'
  gem 'webmock'
end

gem 'rcsv'
gem 'zip_tricks'
gem 'active_admin_scoped_collection_actions'
gem 'chartkick'
gem 'scout_apm'