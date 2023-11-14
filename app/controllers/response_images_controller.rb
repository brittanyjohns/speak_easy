class ResponseImagesController < ApplicationController
  def click
    Rails.logger.debug "ResponseImagesController#click\n#{params.inspect}\n"
    @response_image = ResponseImage.find(params[:id])
    puts "Response image: #{@response_image.inspect}"
    @image = @response_image.image if @response_image
    puts "Image_#{@image.id}: #{@image.label}"
    @response_image.click_count += 1
    @response_image.save
    @response_board = ResponseBoard.find_or_create_by(name: @image.label)
    @source_board = @response_image.source_board
    Rails.logger.debug "response_board: #{@response_board.id} Source board: #{@source_board.id} - response_image.response_board_id: #{@response_image.response_board_id}"
    AskAiJob.perform_async(@image.id)
    # redirect_to @source_board
    render json: { status: "success", redirect_url: response_board_path(@response_board), notice: "Image was successfully cropped & saved." }
  end
end
