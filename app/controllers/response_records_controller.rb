class ResponseRecordsController < ApplicationController
  before_action :set_response_record, except: [:index]

  def index
    @response_records = ResponseRecord.all
  end

  def show
    @response_record = ResponseRecord.find(params[:id])
    @remaining_images = @response_record.remaining_images
  end

  def associate_response_image
    @response_record.response_image_ids << params[:response_image_id].to_i
    @response_record.response_image_ids.uniq!
    @response_record.save
    @response_board = @response_record.response_board
    response_image = ResponseImage.find(params[:response_image_id].to_i)
    @response_board.response_images << response_image unless @response_board.response_images.include?(response_image)
    # redirect_to @response_record
    redirect_to @response_board
  end

  def remove_response_image
    @response_record.response_image_ids = @response_record.response_image_ids - [params[:response_image_id].to_i]
    redirect_to @response_record
  end

  private

  def set_response_record
    @response_record = ResponseRecord.find(params[:id])
  end
end
