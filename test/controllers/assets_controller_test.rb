require "test_helper"

class AssetsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get assets_index_url
    assert_response :success
  end

  test "should get new" do
    get assets_new_url
    assert_response :success
  end

  test "should get create" do
    get assets_create_url
    assert_response :success
  end

  test "should get edit" do
    get assets_edit_url
    assert_response :success
  end

  test "should get update" do
    get assets_update_url
    assert_response :success
  end

  test "should get destroy" do
    get assets_destroy_url
    assert_response :success
  end
end
