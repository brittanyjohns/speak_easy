module ImagesHelper
  def generate_image_button(image)
    button_to "#{icon("fa-regular", "image")} CREATE Image".html_safe, generate_image_path(image), class: "rounded-full", method: :post
  end

  def remove_image_button(board, image)
    button_to "#{icon("fa-solid", "trash")}".html_safe, remove_image_board_path(board, image_id: image), class: "text-red-600 hover:text-red-700 py-1 px-1 rounded-full absolute bottom-0 left-0", method: :post
  end

  def speech_button(image)
    button_to icon("fa-regular", "comment-dots"), speak_image_path(image), class: "btn", method: :post
  end

  def saved_image_link(image, *options)
    size = options[0] || "small"
    puts "size: #{size}"
    unless image.cropped_image.attached? || image.saved_image.attached?
      puts "no image"
      return ""
    end
    image_tag(image.display_image.representation(resize_to_limit: [100, 100]).processed.url, data: { action: "click->speech#speak" })
  end

  def select_image_button(board, image, size: "thumnail")
    unless image.cropped_image.attached? || image.saved_image.attached?
      puts "no image"
      return ""
    end
    button_to(associate_image_board_path(board, image_id: image), data: { turbo: false }) do
      image_tag(image.display_image.representation(resize_to_limit: [100, 100]).processed.url)
    end
  end
end
