class Rack::Attack
	throttle('req/ip', limit: 1000, period: 1.minutes) do |req|
		req.ip
	end
end