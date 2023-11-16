class ResponseBoardsController < ApplicationController
  before_action :authenticate_user!, :set_current_user
  before_action :set_response_board, only: %i[ show ]

  def index
    @response_boards = ResponseBoard.includes(response_images: [image: [cropped_image_attachment: :blob, saved_image_attachment: :blob]]).order(name: :asc).page params[:page]
  end

  def show
    @send_to_ai = "true"
    @response_options = @response_board.response_options.order(click_count: :desc)
  end

  def associate_response_image
    @response_board = ResponseBoard.find(params[:id])
    response_image = ResponseImage.find(params[:image_id])
    @response_board.response_images << response_image unless @response_board.response_images.include?(response_image)

    redirect_to @response_board
  end

  def remove_response_image
    @response_board = ResponseBoard.find(params[:id])
    response_image = ResponseImage.find(params[:image_id])
    @response_board.response_images.delete(response_image)
    redirect_to @response_board
  end

  private

  def set_response_board
    @response_board = ResponseBoard.includes(images: [cropped_image_attachment: :blob, saved_image_attachment: :blob]).find(params[:id])
  end
end
