module ResponseBoardsHelper
  def remove_response_image_button(board, image)
    button_to "#{icon("fa-solid", "trash")}".html_safe, remove_response_image_response_board_path(board, image_id: image), class: "text-red-600 hover:text-red-700 py-1 px-1 rounded-full absolute bottom-0 left-0 text-xs", data: { turbo: false }, method: :post
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

  def response_nav_for(current_repoonse_board, word_list)
    str = "<div class='text-gray-600 text-3xl text-center'> "
    if word_list
      if current_repoonse_board.response_images.count > 0
        current_word = current_repoonse_board.name
        current_index = word_list.index(current_word)
        unless current_index
          str += ""
        end
        previous_word = word_list[current_index - 1] if current_index && current_index > 0
        next_word = word_list[current_index + 1] if current_index && current_index < word_list.count - 1
        unless previous_word || next_word
          str += ""
        end
        next_board = ResponseBoard.find_by(name: next_word)
        previous_board = ResponseBoard.find_by(name: previous_word)
        unless next_board || previous_board
          str += ""
        end
        if next_board && previous_board
          str += "#{link_to(icon("fa-solid", "arrow-left"), response_board_path(previous_board))} #{link_to(icon("fa-solid", "arrow-right"), response_board_path(next_board))}".html_safe
        elsif next_board
          str += "#{link_to(icon("fa-solid", "arrow-right"), response_board_path(next_board))}".html_safe
        elsif previous_board
          str += "#{link_to(icon("fa-solid", "arrow-left"), response_board_path(previous_board))}".html_safe
        end
      end
    end
    str += "</div>"
    str.html_safe
  end
end
