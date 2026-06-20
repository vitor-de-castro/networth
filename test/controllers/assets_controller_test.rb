require "test_helper"

class AssetsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to sign in when not authenticated" do
    get assets_url
    assert_redirected_to new_user_session_path
  end

  test "should redirect new to sign in when not authenticated" do
    get new_asset_url
    assert_redirected_to new_user_session_path
  end
end
