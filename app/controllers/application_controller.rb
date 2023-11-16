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
    current_user.reset_user_selections if current_user
    redirect_to locked_board_path(ResponseBoard.general_board)
    # render partial: "layouts/current_selection"
  end
end
