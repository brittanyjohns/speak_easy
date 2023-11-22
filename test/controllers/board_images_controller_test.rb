require "test_helper"

class BoardImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @board_image = board_images(:one)
  end

  test "should get index" do
    get board_images_url
    assert_response :success
  end

  test "should get new" do
    get new_board_image_url
    assert_response :success
  end

  test "should create board_image" do
    assert_difference("BoardImage.count") do
      post board_images_url, params: { board_image: {  } }
    end

    assert_redirected_to board_image_url(BoardImage.last)
  end

  test "should show board_image" do
    get board_image_url(@board_image)
    assert_response :success
  end

  test "should get edit" do
    get edit_board_image_url(@board_image)
    assert_response :success
  end

  test "should update board_image" do
    patch board_image_url(@board_image), params: { board_image: {  } }
    assert_redirected_to board_image_url(@board_image)
  end

  test "should destroy board_image" do
    assert_difference("BoardImage.count", -1) do
      delete board_image_url(@board_image)
    end

    assert_redirected_to board_images_url
  end
end
