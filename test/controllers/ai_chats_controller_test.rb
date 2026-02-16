require "test_helper"

class AiChatsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get ai_chats_create_url
    assert_response :success
  end
end
