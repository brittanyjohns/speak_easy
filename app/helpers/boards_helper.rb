module BoardsHelper
  def user_board_info(board)
    txt = "<span class='text-xs text-gray-500 float-right'>"
    txt += board.user == current_user ? "PRIVATE" : ""
    txt += "<br> #{board.static ? "STATIC" : ""}"
    txt += "</span>"
    txt.html_safe
  end

  def mark_as_favorite_button(board)
    if board.favorite
      button_to "#{icon("fa-solid", "star")}".html_safe, unfavorite_board_path(board), method: :patch, class: "btn btn-sm btn-outline-secondary"
    else
      button_to "#{icon("fa-regular", "star")}".html_safe, mark_as_favorite_board_path(board), method: :patch, class: "btn btn-sm btn-outline-secondary"
    end
  end

  def current_user_first_favorite_board_button(user)
    return unless user && user.favorite_boards.any?
    board = user.favorite_boards.first
    return unless board
    button_to "#{icon("fa-regular", "star")} #{board.name}".html_safe, locked_board_path(board), method: :get, class: "text-xs text-white bg-blue-500 hover:bg-blue-700 rounded-full px-2 py-1"
  end

  def print_grid(images, columns = 3)
    str = ""
    images.each_slice(columns) do |batch|
      str += "<div class='row'>"
      batch.each do |image|
        next unless image.id
        str += "<div class='col-img' data-toggle='tooltip' data-placement='top' title='#{image.name}'>"
        str += saved_image_link(image)
        str += "</div>"
      end
      str += "</div>"
    end
    str.html_safe
  end

  def theme_color_background(board)
    theme_color = board.theme_color
    case theme_color
    when "blue"
      "bg-blue-100"
    when "green"
      "bg-green-100"
    when "red"
      "bg-red-100"
    when "yellow"
      "bg-yellow-100"
    else
      "bg-gray-100"
    end
  end

  def grid_column_class(board)
    case board.column_count
    when 2
      "grid-cols-2"
    when 3
      "grid-cols-3"
    when 4
      "grid-cols-4"
    when 5
      "grid-cols-5"
    when 6
      "grid-cols-6"
    when 7
      "grid-cols-7"
    when 8
      "grid-cols-8"
    else
      "grid-cols-3"
    end
    # "grid-cols-#{board.column_count}"
  end

  def grid_row_class(board)
    case board.row_count
    when 2
      "grid-rows-2"
    when 3
      "grid-rows-3"
    when 4
      "grid-rows-4"
    when 5
      "grid-rows-5"
    when 6
      "grid-rows-6"
    when 7
      "grid-rows-7"
    when 8
      "grid-rows-8"
    else
      "grid-rows-3"
    end
    # "grid-rows-#{board.row_count}"
  end

  # def print_grid_with_blanks(board)
  #   images = board.images
  #   columns = board.column_count
  #   rows = board.row_count
  #   max_image_count = board.max_image_count
  #   str = "<div class='p-2 #{theme_color_background(board)} rounded-md pb-8'>"
  #   str += "<div class='grid grid-cols-1 sm:grid-cols-2 md:#{grid_column_class(board)} gap-4 place-items-center'>"

  #   placeholders = max_image_count - images.length
  #   images.each do |image|
  #     str += "<div class='relative max-h-200 overflow-hidden' data-controller='speech'   data-speech-id='#{image.id}' data-speech-label='#{image.label}' data-speech-send-to-ai='#{@send_to_ai === "true" ? "true" : "false"}'>"
  #     str += saved_image_link(image, "small")
  #     str += remove_image_button(board, image) unless action_name == "locked"
  #     str += "</div>"
  #   end
  #   placeholders.times do
  #     str += "<div class='relative max-h-200 overflow-hidden'>"
  #     str += "<div class='box-border flex bg-gray-100 border-2 border-gray-300 border-dashed rounded-md h-32 w-32'>"
  #     str += "</div>"
  #     str += "</div>"
  #   end
  #   str += "</div>"
  #   str += "</div>"
  #   str.html_safe
  # end
end
