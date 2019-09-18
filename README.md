![](https://github.com/MonkeyTech/quana-server/workflows/Rails%20Unit%20Tests/badge.svg)

# Archicebus

Archicebus is a Ruby on Rails server-side project boilerplate. It includes most of Monkeytech's infrastructure modules and aims to provide guidelines and best practices for projects developed inside the company.

Archicebus is named after the oldest known monkey: 
[Check it out!](https://en.wikipedia.org/wiki/Archicebus) 

#### Features Breakdown
* [Getting started](#setup)
* [Configuration and security](#config)
* [Extensions to known libraries](#extensions)
* [Common behaviors and concerns](#concerns)
* [AppSettings' key-value storage](#settings)
* [I18n using Mobility](#i18n)
* [Currency handling using MoneyRails](#currency)
* [Enhanced Select2 support](#select2)
* [ActiveAdmin hacks and role management](#admin)
* [2FA Using GoogleAuthenticator](#2fa)
* [ActionMailer Templates](#mailer)
* [File uploads using carrierwave](#uploads)
* [New helpers and input types](#helpers)
* [Multiple SMS gateway support](#sms)
* [iOS & Android push notifications](#notifications)
* [REST APIs guidelines and infrastructure](#rest)

## Getting started <a name="setup"></a>
Clone the repository and reset the working directory:
```
git clone [ARCHICEBUS REPOSITORY URL] [PROJECT NAME]
cd /[PROJECT NAME]
rm -rf .git
git init
```
Then run:
```
bundle install
```
> NOTE: you may want to adjust the gemfile beforehand, removing gem support for any unnecessary features. See the next sections for more information.

Replace all instances of the Archicebus name with your actual project name. These include:

**application.rb**
```ruby
module Archicebus
	class Application < Rails::Application
	...
end
``` 

**package.json**
```json
{
  "name": "archicebus",
  "private": true,
  "dependencies": {}
}
``` 

**database.yml**
```yaml
default: &default
  database: archicebus-dev
``` 

**cable.yml**
```yaml
production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
  channel_prefix: archicebus_production
``` 

Finally, set the project name and server domain:
```yaml
# application.yml

defaults: &defaults
  project_name: 'Archicebus'

...

development:
  <<: *defaults

  server_domain: 'localhost:3000'

...

staging:
  <<: *defaults

  server_domain: 'archicebus-staging.herokuapp.com'

...

production:
  <<: *defaults
  
  server_domain: 'archicebus-production.herokuapp.com'
``` 
This will automatically adjust page titles & urls across the entire application.

#### Rails 5.2 secret credentials
Archicebus uses a monkey-patched version of Rails 5.2's secret credentials mechanism, inspired by [this github thread](https://github.com/rails/rails/pull/33521) and implemented as part of **application.rb**:
```ruby
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
```
This allows for environment-specific credential files & keys. To create a file for a specific environment:
* Create a _[environment].key_ file with the desired encryption key like so:
```ruby
533739f0f8111fb331b3aaf6fda93598 # this is an exmaple
```
The key itself can be generated using SecureRandom's hex method.
> NOTE: the production environment uses the default _master.key_ instead of _production.key_.   
* Then, run:
```
RAILS_ENV=[ENVIRONMENT] EDITOR="subl --wait" rails credentials:edit
``` 
from any terminal window to generate the actual credentials file. Use credentials.template.yml as a general guide.
> NOTE: You may have to add SECRET_KEY_BASE=[DUMMY] to the above command to temporarily skip the default validation. 


## Configuration and security <a name="config"></a>
Archicebus has several security features enabled by default. These include:

#### IP whitelisting & request throttling at the application level
Archicebus uses the [rack-attack](https://github.com/kickstarter/rack-attack) gem to support IP whitelisting and request throttling. The basic setup file provides:
* Full access from localhost
* Restricted admin access from whitelisted IPs only (set using an ENV variable)
* Request throttling of 1k\m per IP
```ruby
# initializers/rack_attack.rb

class Rack::Attack
	WHITELISTED_IPS = ENV["WHITELISTED_IPS"] ? ENV["WHITELISTED_IPS"].strip.split(',') : []

	Rack::Attack.safelist('allow full access from localhost') do |req|
		'127.0.0.1' == req.ip || '::1' == req.ip
	end

	Rack::Attack.safelist('allow admin access only from whitelist') do |req|
		req.path.include?("/admin") && WHITELISTED_IPS.include?(req.ip)
	end

	Rack::Attack.blocklist('block all other requests') do |req|
		true
	end

	throttle('req/ip', limit: 1000, period: 1.minutes) do |req|
		req.ip
	end
end
```
Please note that this setup is very basic, and should probably be adjusted to suit the project's needs.

#### CORS
Archicebus uses Rack::Cors to setup its CORS policy. By default, requests of all types are allowed, but only from localhost. As for headers, the standard Access-Token authentication header (see [REST APIs guidelines and infrastructure](#rest)) is whitelisted as well as several others, required for Kaminari's pagination mechanism (see [here](https://github.com/monterail/grape-kaminari)). While this is ok for most native mobile backend projects (where CORS doesn't usually apply), it certainly requires some tweaking when dealing with web clients. At the very least, you should add the website's url to the list of allowed origins:

**application.rb**
```ruby
config.middleware.insert_before 0, Rack::Cors do
	allow do
		origins 'localhost:3000', '127.0.0.1:3000'
		resource '*', headers: :any, 
			methods: [:get, :post, :options, :delete], 
			expose: ['Access-Token', 'x-page', 'x-per-page', 'x-next-page', 'x-total-pages', 'x-total']
	end
end
```
At any rate, be sure to review this before going to production.

#### Content security policy (CSP)


## 2FA Using GoogleAuthenticator <a name="2fa"></a>
By default admin users will be required to use 2fa on production.
For this to work you will need add an otp key to credentials.

First generate a key in rails console: 
```
cipher = OpenSSL::Cipher.new('aes-256-cbc')
cipher.encrypt
secret_key = cipher.random_key
Base64.strict_encode64(secret_key) # => here's your key
```
 
Then add it to encrypted credentials:

```
# credentials.[environment].yml

...
opt_encryption_key: [key]
... 
```

2fa relies on the following gems
```
gem 'devise'
gem 'devise-two-factor'
gem 'rqrcode'
```

2fa hooks into admin session creation flow by overriding
`/app/controllers/active_admin/devise/`
`/app/views/active_admin/devise/`
