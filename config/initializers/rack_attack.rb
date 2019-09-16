class Rack::Attack
	WHITELISTED_IPS = ENV["WHITELISTED_IPS"] ? ENV["WHITELISTED_IPS"].strip.split(',') : []

	Rack::Attack.safelist('allow full access from localhost') do |req|
		'127.0.0.1' == req.ip || '::1' == req.ip
	end

	Rack::Attack.safelist('allow admin access only from whitelist') do |req|
		req.path.include?("/admin") && WHITELISTED_IPS.include?(req.ip)
	end

	Rack::Attack.safelist('allow swagger documentation access only from whitelist') do |req|
		req.path.include?("/swagger") && WHITELISTED_IPS.include?(req.ip)
	end

	Rack::Attack.safelist('allow public api access') do |req|
		req.path.include?("/api")
	end

	Rack::Attack.blocklist('block all other requests') do |req|
		true
	end

	throttle('req/ip', limit: 1000, period: 1.minutes) do |req|
		req.ip
	end
end