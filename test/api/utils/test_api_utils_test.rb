require 'test_helper'

class APIUtilsTest < ActiveSupport::TestCase
	include Rack::Test::Methods
	# /v1/utils/meta

	test 'GET responds 200' do
		get '/api/v1/utils/meta'
		assert_response_ok
	end

end