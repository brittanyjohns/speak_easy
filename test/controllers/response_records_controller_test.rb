require "test_helper"

class ResponseRecordsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get response_records_index_url
    assert_response :success
  end

  test "should get show" do
    get response_records_show_url
    assert_response :success
  end
end
