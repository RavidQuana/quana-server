ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
MiniTest::Reporters.use!

class ActiveSupport::TestCase
  include Rack::Test::Methods

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Setup all tests
  def app
    Rails.application
  end

  setup do
    # shared setup
  end

  def parse_response
    res = JSON.parse(last_response.body)
    assert last_response.ok?, res
    assert_not_empty(res['data'])
    res['data']
  end

  def assert_response_empty
    res = JSON.parse(last_response.body)
    assert last_response.ok?, res
    assert_empty(res['data'])
  end

  def assert_response_unauthorized
    res = JSON.parse(last_response.body)
    assert last_response.unauthorized?, res
  end

  def assert_response_ok
    res = JSON.parse(last_response.body)
    assert last_response.ok?, res
  end

  def assert_response_bad_request
    res = JSON.parse(last_response.body)
    assert last_response.bad_request?, res
  end

  def assert_response_server_error
    res = JSON.parse(last_response.body)
    assert last_response.server_error?, res
  end


  def assert_json_has_keys(json, keys)
    missing_keys = []
    keys.each do |key|
      missing_keys << key.to_s unless json.has_key?(key.to_s) or json.has_key?(key.to_sym)
    end
    assert(missing_keys.empty?, "Missing keys: #{missing_keys}\n\tHash: #{json}")
  end

  def stub_http_requests
    WebMock.disable_net_connect!(allow: ['notify.bugsnag.com', /chromedriver/], allow_localhost: true)
    #stub_request(:any, /amazonaws/)
    #stub_request(:get, /thumbnail\.jpg/).to_return(body: File.new('test/assets/thumbnail.jpg'), status: 200)
    #stub_request(:get, /audio\.wav/).to_return(body: File.new('test/assets/audio.wav'), status: 200)
  end
end
