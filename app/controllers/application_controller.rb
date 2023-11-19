class ApplicationController < ActionController::Base
  # before_action :authenticate_user!, :set_current_user, unless: :devise_controller?
  skip_before_action :verify_authenticity_token

  def set_current_user
    @current_user = current_user
    @current_user.ensure_current_user_selection if @current_user
    @current_word_list = @current_user.current_word_list if @current_user
  end

  def after_sign_in_path_for(resource)
    boards_path
  end

  def clear_selection
    if params["response_board_id"]
      @current_response_board = ResponseBoard.find(params["response_board_id"])
    end
    if params["commit"] == "Clear"
      current_user.reset_user_selections if current_user
      @current_board = Board.general_board
      redirect_to locked_board_path(@current_board) if @current_board
      redirect_to root_url unless @current_board
    else
      parse_word_list
    end
  end

  def parse_word_list
    matching_words = []
    user_input = params["user_input"]
    remaining = nil
    current_user.current_word_list.each do |word|
      if user_input.include?(word)
        matching_words << word
        remaining = user_input.lstrip.delete_prefix(word)
        user_input = remaining
      end
    end

    if remaining.blank?
      if matching_words.blank? && user_input.blank?
        redirect_to response_boards_path, notice: "Nothing to create"
        return
      elsif matching_words.blank? && user_input.present?
        create_image_and_ask_ai(user_input)
        current_user.make_selection(user_input)
        redirect_to response_board_path(@response_board), notice: "Your images are generating."
        return
      end
      word_list = matching_words[0..-1]
      create_image_and_ask_ai(matching_words.last, word_list)
      redirect_to response_board_path(@response_board), notice: "Your images are generating."
    else
      stripped_remaining = remaining.strip
      word_list = matching_words << stripped_remaining
      create_image_and_ask_ai(stripped_remaining, word_list)
      current_user.make_selection(stripped_remaining)
      last_response_board = ResponseBoard.find_by(name: matching_words[-2])
      last_response_board.images << @image unless last_response_board.images.include?(@image)
      last_response_board.save

      redirect_to response_board_path(@response_board), notice: "Your images are generating."
    end
  end

  def create_image_and_ask_ai(label_string, word_list = nil)
    @image = Image.searchable_images_for(@current_user).find_by(label: label_string)
    @image = Image.create(label: label_string, private: false, category: "None", ai_generated: true, send_request_on_save: ResponseBoard::CREATE_AI_IMAGES) unless @image

    @response_board = ResponseBoard.find_or_create_by(name: label_string)
    @response_image = @response_board.response_images.find_or_create_by(image_id: @image.id, label: label_string)
    @response_board.create_response_record(@image.label, @current_user.id)

    AskAiJob.perform_async(@image.id, @response_image.id, word_list&.flatten, @current_user&.id)
  end
end
