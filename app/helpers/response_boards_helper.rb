module ResponseBoardsHelper
  def remove_response_image_button(board, image)
    button_to "#{icon("fa-solid", "trash")}".html_safe, remove_response_image_response_board_path(board, image_id: image), class: "text-red-600 hover:text-red-700 py-1 px-1 rounded-full absolute bottom-0 left-0 text-xs", method: :post
  end

  def add_response_image_button(board, image, size: "thumnail")
    unless image.cropped_image.attached? || image.saved_image.attached?
      puts "no image"
      return ""
    end
    button_to(associate_response_image_response_board_path(board, image_id: image), data: { turbo: false }) do
      image_tag(image.display_image.representation(resize_to_limit: [100, 100]).processed.url)
    end
  end
end
