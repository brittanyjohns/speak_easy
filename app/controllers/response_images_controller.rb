class ResponseImagesController < ApplicationController
  before_action :authenticate_user!, :set_current_user

  def click
    @response_image = ResponseImage.find(params[:id])
    situation = params[:situation]
    puts "Situation: #{situation}"
    @image = @response_image.image if @response_image
    throw "NO IMAGE FOUND" unless @image
    unless @image.label == params[:label]
      throw "Image label mismatch"
    end

    @current_user.make_selection(@image.label, situation)
    word_list = @current_user.current_word_list

    @response_image.click_count += 1
    @response_board = ResponseBoard.find_or_create_by(name: @image.label)
    @response_board.create_response_record(@image.label, @current_user.id, situation) if @response_board
    AskAiJob.perform_async(@image.id, @response_image.id, word_list, @current_user.id)
    render json: { status: "success", redirect_url: response_board_path(@response_board) }
  end

  def next
    puts "NEXT params: #{params}"
    @response_image = ResponseImage.find(params[:id])
    @image = @response_image.image if @response_image
    throw "NO IMAGE FOUND" unless @image
    @response_image.click_count += 1
    @response_image.save
    render json: { status: "success", redirect_url: response_image_path(@response_image) }
  end
end
