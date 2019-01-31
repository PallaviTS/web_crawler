require 'test_helper'

class SitesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get sites_create_url
    assert_response :success
  end

end
