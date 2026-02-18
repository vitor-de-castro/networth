require "test_helper"

class CurrenciesControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get currencies_update_url
    assert_response :success
  end
end
