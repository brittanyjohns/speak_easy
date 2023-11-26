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

  # def next
  #   puts "NEXT params: #{params}"
  #   @response_image = ResponseImage.find(params[:id])
  #   @image = @response_image.image if @response_image
  #   throw "NO IMAGE FOUND" unless @image
  #   @response_image.click_count += 1
  #   @response_image.save
  #   @response_board = @response_image.response_board
  #   @next_board = @response_board.next
  #   render json: { status: "success", redirect_url: response_board_path(@response_board) }
  # end

  def next
    @response_image = ResponseImage.find(params[:id])
    @response_board = @response_image.response_board
    @next_board = @response_board.next_board
    @current_user.make_selection(@response_image.label)
    word_list = @current_user.current_word_list
    if @next_board
      render json: { status: "success", redirect_url: response_board_path(@next_board) }
    else
      render json: { status: "success", redirect_url: response_board_path(@response_board) }
    end
  end
end
