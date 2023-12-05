module ImagesHelper
  def generate_image_button(image)
    button_to "#{icon("fa-regular", "image")} CREATE Image".html_safe, generate_image_path(image), class: "rounded-full", method: :post
  end

  def remove_image_button(board, image)
    button_to "#{icon("fa-solid", "trash")}".html_safe, remove_image_board_path(board, image_id: image.id), class: "text-red-600 hover:text-red-700 py-1 px-1 rounded-full absolute bottom-0 left-0", method: :post
  end

  def purge_saved_images_button(image)
    button_to "#{icon("fa-solid", "trash")} Delete Image".html_safe, purge_saved_images_image_path(image.id), class: "text-red-600 hover:text-red-700 py-1 px-1 rounded-full", method: :post
  end

  def speech_button(image)
    button_to icon("fa-regular", "comment-dots"), speak_image_path(image), class: "btn", method: :post
  end

  def saved_image_link(image)
    unless image.cropped_image.attached? || image.saved_image.attached?
      str = "<div class='absolute top-0 left-0 w-full h-full bg-gray-200 flex items-center justify-center text-gray-400 text-2xl font-bold' data-action='click->speech#speak'>#{image.label.upcase}</div>"
      return str.html_safe
    end
    image_tag(image.display_image.representation(resize_to_limit: [100, 100]).processed.url, data: { action: "click->speech#speak" })
  end

  # def select_image_button(board, image, size: "thumnail")
  #   unless image.display_image.attached?
  #     puts "no image"
  #     str = "<div class='absolute top-0 left-0 w-full h-full bg-gray-200 flex items-center justify-center text-gray-400 text-2xl font-bold'>#{image.label.upcase}</div>"
  #     return button_to(associate_image_board_path(board, image_id: image), data: { turbo: false }, class: "relative w-full h-0 pb-[100%]") do
  #              str.html_safe
  #            end
  #     # return button_to(image.label, associate_image_board_path(board, image_id: image), data: { turbo: false })
  #   end
  #   button_to(associate_image_board_path(board, image_id: image), data: { turbo: false }, class: "relative w-full h-0 pb-[100%]") do
  #     image_tag(image.display_image.representation(resize_to_limit: [200, 200]).processed.url)
  #   end
  # end
end
