module ResponseRecordsHelper
  def select_response_record_image_button(resource_record, response_image, size: "thumnail")
    str = "<div class='absolute top-0 left-0 w-full h-full bg-gray-200 flex items-center justify-center text-gray-400 text-2xl font-bold'>#{response_image.label.upcase}</div>"
    return button_to(associate_response_image_response_record_path(resource_record, response_image_id: response_image), data: { turbo: false }, class: "relative w-full h-0 pb-[100%]") do
             str.html_safe
           end
    # unless response_image.display_image.attached?
    #   puts "no image"
    #   str = "<div class='absolute top-0 left-0 w-full h-full bg-gray-200 flex items-center justify-center text-gray-400 text-2xl font-bold'>#{response_image.label.upcase}</div>"
    #   return button_to(associate_response_image_response_record_path(resource_record, response_image_id: response_image), data: { turbo: false }, class: "relative w-full h-0 pb-[100%]") do
    #            str.html_safe
    #          end
    #   # return button_to(image.label, associate_image_board_path(board, image_id: image), data: { turbo: false })
    # end
    # button_to(associate_response_image_response_record_path(resource_record, response_image_id: response_image), data: { turbo: false }, class: "relative w-full h-0 pb-[100%]") do
    #   image_tag(response_image.display_image.representation(resize_to_limit: [200, 200]).processed.url)
    # end
  end
end
