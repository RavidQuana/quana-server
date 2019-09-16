ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
MiniTest::Reporters.use!

class ActiveSupport::TestCase
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
end
