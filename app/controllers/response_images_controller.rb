class ResponseImagesController < ApplicationController
  before_action :authenticate_user!, :set_current_user

  def click
    Rails.logger.debug "ResponseImagesController#click\n#{params.inspect}\n"
    @response_image = ResponseImage.find(params[:id])
    @image = @response_image.image if @response_image
    throw "NO IMAGE FOUND" unless @image
    unless @image.label == params[:label]
      throw "Image label mismatch"
    end
    # if !params[:word_list].blank?
    #   # @current_user.add_to_user_selections(params[:word_list])
    #   @current_user.reset_user_selections(params[:word_list])
    # end
    @current_user.make_selection(@image.label)
    word_list = @current_user.current_word_list
    # word_list = params[:word_list].concat(@image.label)

    Rails.logger.debug "word_list: #{word_list} - paramns- #{params[:word_list]}}"
    # @current_user.reset_user_selections(word_list)

    @response_image.click_count += 1
    # @response_image.save
    @response_board = ResponseBoard.find_or_create_by(name: @image.label)
    Rails.logger.debug "*****response_board: #{@response_board.id} - response_image.response_board_id: #{@response_image.response_board_id}"
    AskAiJob.perform_async(@image.id, @response_image.id, word_list, @current_user.id)
    render json: { status: "success", redirect_url: response_board_path(@response_board), notice: "Image was successfully cropped & saved." }
  end
end
