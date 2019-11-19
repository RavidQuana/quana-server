require 'test_helper'

class APIUsersTest < ActiveSupport::TestCase
  # /v1/users/me/

  class UpdateUserTest < APIUsersTest

    test 'POST returns ok' do
        post '/api/v1/users/me', {}
        assert_response_ok
    end

    # test 'POST updates user information' do
    #   payload = {

    #   }
    #   assert_difference 'User.count', 1 do
    #     post '/api/v1/users/me', payload
    #     assert_response_ok
    #   end
    # end

    # test 'POST returns expected fields' do
    #   post '/api/v1/customers/me/requests', @payload
    #   res = parse_response

    #   assert_equal(@payload[:tags], res['tags'])
    #   assert_equal(@payload[:description], res['description'])
    #   assert_equal(@category.id, res['category']['id'])
    #   assert_equal(@payload[:subcategory_ids], res['subcategories'].map { |sc| sc['id'] })
    #   assert_equal(@payload[:tags], res['tags'])

    #   assert_equal(@payload[:location][:name], res['location']['name'])
    #   assert_not_nil(res['professionals'])
    # end

    # test 'POST customer can create a new request without location' do
    #   @payload = @payload.except(:location)
    #   assert_difference '@customer.requests.count', 1 do
    #     post '/api/v1/customers/me/requests', @payload
    #     assert_response_ok
    #   end
    # end

    # test 'POST reuses already existing locations' do
    #   assert_difference 'Location.count', 1 do
    #     post '/api/v1/customers/me/requests', @payload
    #     post '/api/v1/customers/me/requests', @payload
    #   end
    # end


  end


end