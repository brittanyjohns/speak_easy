class ResponseImagesController < ApplicationController
  def click
    puts "ResponseImagesController#click"
    @response_image = ResponseImage.find(params[:id])
    puts "Response image: #{@response_image.inspect}"
    @image = @response_image.image if @response_image
    @response_image.click_count += 1
    @response_image.save
    @response_board = ResponseBoard.find_or_create_by(name: @image.label)
    AskAiJob.perform_async(@image.id)
    render json: { status: "success", redirect_url: response_board_path(@response_board), notice: "Image was successfully cropped & saved." }
  end
end
