class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update_selection]

  def index
    @users = User.all.page params[:page]
  end

  def show
  end

  def update_selection
    if params["response_board_id"]
      @current_response_board = ResponseBoard.find(params["response_board_id"])
    end
    if params["commit"] == "Clear"
      @user.reset_user_selections if @user
      @current_board = Board.general_board
      redirect_back_or_to locked_board_path(@current_board) if @current_board
      redirect_back_or_to root_url unless @current_board
    else
      parse_word_list
    end
  end

  private

  def parse_word_list
    matching_words = []
    user_input = params["user_input"]
    user_input = user_input.downcase if user_input
    situation = params["situation"]
    remaining = nil
    puts "\n\n\n****SITUATION: #{situation}****\n\n\n"
    @user.current_word_list.each do |word|
      if user_input.include?(word)
        matching_words << word
        remaining = user_input.lstrip.delete_prefix(word)
        user_input = remaining
      end
    end

    if remaining.blank?
      if matching_words.blank? && user_input.blank?
        redirect_back_or_to response_boards_path, notice: "Nothing to create"
        return
      elsif matching_words.blank? && user_input.present?
        create_image_and_ask_ai(user_input, nil)
        @user.make_selection(user_input, situation)
        redirect_back_or_to image_path(@image), notice: "Your images are generating. user_input #{user_input}"
        # redirect_to response_board_path(@response_board), notice: "Your images are generating. user_input #{user_input}"
        return
      end
      word_list = matching_words[0..-1]
      create_image_and_ask_ai(matching_words.last, word_list)
      redirect_back_or_to image_path(@image), notice: "Your images are generating. #{word_list}"
    else
      stripped_remaining = remaining.strip
      word_list = matching_words << stripped_remaining
      create_image_and_ask_ai(stripped_remaining, word_list)
      @user.make_selection(stripped_remaining, situation)
      last_response_board = ResponseBoard.find_by(name: matching_words[-2])
      last_response_board.images << @image unless last_response_board.images.include?(@image)
      last_response_board.save

      redirect_back_or_to image_path(@image), notice: "Your images are generating."
    end
  end

  def create_image_and_ask_ai(label_string, word_list = nil)
    @image = Image.searchable_images_for(@user).find_by(label: label_string)
    @image = Image.create(label: label_string, private: false, category: "None", ai_generated: true, send_request_on_save: ResponseBoard::CREATE_AI_IMAGES) unless @image

    @response_board = ResponseBoard.find_or_create_by(name: label_string)
    @response_image = @response_board.response_images.find_or_create_by(image_id: @image.id, label: label_string)
    @response_board.create_response_record(@image.label, @user.id, @user.current_situation) if @response_board
    @user.reload if @user

    AskAiJob.perform_async(@image.id, @response_image.id, word_list&.flatten, @user&.id) if @ai_enabled
  end

  def set_user
    @user = User.find(params[:id])
  end
end
