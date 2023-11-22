require "application_system_test_case"

class BoardImagesTest < ApplicationSystemTestCase
  setup do
    @board_image = board_images(:one)
  end

  test "visiting the index" do
    visit board_images_url
    assert_selector "h1", text: "Board images"
  end

  test "should create board image" do
    visit board_images_url
    click_on "New board image"

    click_on "Create Board image"

    assert_text "Board image was successfully created"
    click_on "Back"
  end

  test "should update Board image" do
    visit board_image_url(@board_image)
    click_on "Edit this board image", match: :first

    click_on "Update Board image"

    assert_text "Board image was successfully updated"
    click_on "Back"
  end

  test "should destroy Board image" do
    visit board_image_url(@board_image)
    click_on "Destroy this board image", match: :first

    assert_text "Board image was successfully destroyed"
  end
end
