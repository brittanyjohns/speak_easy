require "test_helper"

class ResponseBoardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get response_boards_index_url
    assert_response :success
  end

  test "should get show" do
    get response_boards_show_url
    assert_response :success
  end
end
