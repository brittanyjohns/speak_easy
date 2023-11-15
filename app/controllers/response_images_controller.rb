class ResponseImagesController < ApplicationController
  before_action :authenticate_user!, :set_current_user

  def click
    Rails.logger.debug "ResponseImagesController#click\n#{params.inspect}\n"
    @response_image = ResponseImage.find(params[:id])
    puts "Response image: #{@response_image.inspect}"
    @image = @response_image.image if @response_image
    throw "NO IMAGE FOUND" unless @image
    @current_user.make_selection(@image.label)
    puts "Image_#{@image.id}: #{@image.label}"
    unless @image.label == params[:label]
      throw "Image label mismatch"
    end
    @response_image.click_count += 1
    @response_image.save
    @response_board = ResponseBoard.find_or_create_by(name: @image.label)
    Rails.logger.debug "response_board: #{@response_board.id} - response_image.response_board_id: #{@response_image.response_board_id}"
    AskAiJob.perform_async(@image.id, @response_image.id, @current_user.current_word_list)
    render json: { status: "success", redirect_url: response_board_path(@response_board), notice: "Image was successfully cropped & saved." }
  end
end
