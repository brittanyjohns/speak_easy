class ApplicationController < ActionController::Base
  # before_action :authenticate_user!, :set_current_user, unless: :devise_controller?
  skip_before_action :verify_authenticity_token

  def set_current_user
    @current_user = current_user
  end

  def after_sign_in_path_for(resource)
    boards_path
  end

  def clear_selection
    puts "PARAMS: #{params.inspect}"
    if params["commit"] == "Clear"
      current_user.reset_user_selections if current_user
      @current_response_board = ResponseBoard.general_board
      redirect_to response_boards_path
    else
      # word_list = params["current_word_list"]
      # @current_response_board = ResponseBoard.find_or_create_by(name: params["current_word_list"])
      # @response_image = @current_response_board.reload.response_images.first
      # @image = @response_image.image
      # puts "SENDING to AI: #{image.label} - #{@response_image.label} - #{word_list}"
      # AskAiJob.perform_async(@image.id, @response_image.id, word_list)
      parse_word_list
    end
    # redirect_to response_board_path(@current_response_board)

    # render partial: "layouts/current_selection"
  end

  def parse_word_list
    puts "Current user current_word_list: #{current_user.current_word_list}"
    matching_words = []
    user_input = params["user_input"]
    remaining = nil
    current_user.current_word_list.each do |word|
      puts "WORD: #{word}"
      puts "USER INPUT: #{user_input}"
      if user_input.include?(word)
        puts "USER INPUT INCLUDES WORD: #{word}"
        matching_words << word
        remaining = user_input.lstrip.delete_prefix(word)
        puts "REMAINING: #{remaining}"
        user_input = remaining
      end
    end

    puts "REMAINING: #{remaining}"
    puts "MATCHING WORDS: #{matching_words}"
    if remaining.blank?
      if matching_words.blank? && user_input.blank?
        puts "MATCHING & INPUT IS BLANK"
        redirect_to response_boards_path, notice: "Nothing to create"
        return
      elsif matching_words.blank? && user_input.present?
        create_image_and_ask_ai(user_input)
        current_user.make_selection(user_input)
        redirect_to response_board_path(@response_board), notice: "Your image is generating from user_input. #{user_input} "
        return
      end
      puts "REMAINING IS BLANK"
      word_list = matching_words[0..-1]
      puts "WORD LIST: #{word_list}"
      create_image_and_ask_ai(matching_words.last, word_list)
      redirect_to response_board_path(@response_board), notice: "Your image is generating from matching_words. #{matching_words.last} - #{word_list}"
      # redirect_to response_boards_path, notice: "Nothing to create"
    else
      puts "REMAINING IS NOT BLANK"
      stripped_remaining = remaining.strip
      word_list = matching_words << stripped_remaining
      create_image_and_ask_ai(stripped_remaining, word_list)
      current_user.make_selection(stripped_remaining)
      redirect_to response_board_path(@response_board), notice: "Your image is generating from new word plus existing #{stripped_remaining} - #{word_list}"
    end
  end

  def create_image_and_ask_ai(label_string, word_list = nil)
    @image = Image.find_or_create_by(label: label_string, private: false, category: "None", ai_generated: true)
    @response_board = ResponseBoard.find_or_create_by(name: label_string)
    @response_image = @response_board.response_images.find_or_create_by(image_id: @image.id, label: label_string)
    AskAiJob.perform_async(@image.id, @response_image.id, word_list&.flatten, current_user&.id)
  end
end
