module BoardImagesHelper
  def select_image_button(board, image)
    if board.images.include?(image)
      remove_image_button(board, image)
    else
      add_image_button(board, image)
    end
  end

  def add_image_button(board, image)
    button_to(associate_image_board_path(board, image_id: image), data: { turbo: false }, class: "relative w-full h-0 pb-[100%]") do
      display_image_for(image)
    end
  end

  def remove_board_image_button(board, image)
    button_to(remove_image_board_path(board, image_id: image), data: { turbo: false }, class: "relative w-full h-0 pb-[100%]") do
      display_image_for(image)
    end
  end

  def display_image_for(image)
    str = ""
    if !image.display_image.attached?
      str += "<div class='h-52 w-52 text-gray-400 text-2xl font-bold grid justify-items-center items-center shadow mx-auto my-auto'><span class='mx-auto my-auto'>#{image.label.upcase}</span></div>".html_safe
    else
      str += image_tag(image.display_image.representation(resize_to_limit: [208, 208]).processed.url, class: "shadow mx-auto my-auto")
    end
    if @board.present? && @board.images.include?(image)
      str += button_to "#{icon("fa-solid", "trash")}".html_safe, remove_image_board_path(@board, image_id: image.id), class: "text-red-600 hover:text-red-700 py-1 px-1 float-right", method: :post
    end
    str.html_safe
  end

  # def remove_image_button(board, image)
  #   button_to(remove_image_board_path(board, image_id: image), data: { turbo: false }, class: "absolute top-0 right-0 p-1 bg-red-500 text-white rounded-full") do
  #     content_tag(:span, "x", class: "text-xl")
  #   end
  # end
end
