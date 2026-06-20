require "test_helper"

class AiChatsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to sign in when not authenticated" do
    post ask_ai_path, params: { message: "test" }
    assert_redirected_to new_user_session_path
  end
end
