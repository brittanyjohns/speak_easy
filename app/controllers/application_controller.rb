class ApplicationController < ActionController::Base
  # before_action :authenticate_user!, :set_current_user, unless: :devise_controller?
  skip_before_action :verify_authenticity_token
  before_action :set_ai_mode

  def set_ai_mode
    if user_signed_in?
      @ai_enabled = current_user.ai_enabled
    else
      @ai_enabled = ENV.fetch("AI_ENABLED", false)
    end
  end

  def ai
    if user_signed_in?
      current_user.update(ai_enabled: !current_user.ai_enabled)
      render json: { status: "success", ai_enabled: current_user.ai_enabled, redirect_to: boards_path }
    else
      redirect_to root_url, notice: "You must be signed in to change AI mode"
    end
  end

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
    user_input = user_input.downcase if user_input
    situation = params["situation"]
    remaining = nil
    puts "\n\n\n****SITUATION: #{situation}****\n\n\n"
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
        create_image_and_ask_ai(user_input, nil, situation)
        current_user.make_selection(user_input, situation)
        redirect_to response_board_path(@response_board), notice: "Your images are generating. user_input #{user_input}"
        return
      end
      word_list = matching_words[0..-1]
      create_image_and_ask_ai(matching_words.last, word_list, situation)
      redirect_to response_board_path(@response_board), notice: "Your images are generating. #{word_list}"
    else
      stripped_remaining = remaining.strip
      word_list = matching_words << stripped_remaining
      create_image_and_ask_ai(stripped_remaining, word_list, situation)
      current_user.make_selection(stripped_remaining, situation)
      last_response_board = ResponseBoard.find_by(name: matching_words[-2])
      last_response_board.images << @image unless last_response_board.images.include?(@image)
      last_response_board.save

      redirect_to response_board_path(@response_board), notice: "Your images are generating."
    end
  end

  def create_image_and_ask_ai(label_string, word_list = nil, situation = nil)
    @image = Image.searchable_images_for(@current_user).find_by(label: label_string)
    @image = Image.create(label: label_string, private: false, category: "None", ai_generated: true, send_request_on_save: ResponseBoard::CREATE_AI_IMAGES) unless @image

    @response_board = ResponseBoard.find_or_create_by(name: label_string)
    @response_image = @response_board.response_images.find_or_create_by(image_id: @image.id, label: label_string)
    @response_board.create_response_record(@image.label, @current_user.id, situation) if @response_board
    @current_user.reload if @current_user

    AskAiJob.perform_async(@image.id, @response_image.id, word_list&.flatten, @current_user&.id) if @ai_enabled
  end
end
