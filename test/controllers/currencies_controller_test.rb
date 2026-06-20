require "test_helper"

class CurrenciesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to sign in when not authenticated" do
    patch update_currency_path, params: { currency: "USD" }
    assert_redirected_to new_user_session_path
  end
end
