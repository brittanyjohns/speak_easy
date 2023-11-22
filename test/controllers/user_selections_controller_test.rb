require "test_helper"

class UserSelectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_selections_index_url
    assert_response :success
  end

  test "should get show" do
    get user_selections_show_url
    assert_response :success
  end
end
