module ImagesHelper
  def generate_image_button(image)
    button_to "#{icon("fa-regular", "image")} CREATE Image".html_safe, generate_image_path(image), class: "rounded-full", method: :post
  end

  def remove_image_button(board, image)
    button_to "#{icon("fa-solid", "trash")}".html_safe, remove_image_board_path(board, image_id: image), class: "text-red-600 hover:text-red-700 py-2 px-4 rounded-full absolute bottom-0 left-0", method: :post
  end

  def speech_button(image)
    button_to icon("fa-regular", "comment-dots"), speak_image_path(image), class: "btn", method: :post
  end

  def saved_image_link(image, size: "500x500")
    unless image.saved_image.attached?
      puts "no saved image"
      return ""
    end
    image_tag(image.saved_image, size: size, class: "w-full h-auto object-cover", data: { action: "click->speech#speak" })
  end

  def select_image_button(board, image, size: "500x500")
    unless image.saved_image.attached?
      puts "no saved image"
      return ""
    end
    button_to(associate_image_board_path(board, image_id: image), data: { turbo: false }) do
      image_tag(image.saved_image, size: size, class: "")
    end
  end
end
