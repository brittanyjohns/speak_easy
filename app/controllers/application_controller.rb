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
    @ai_global = ENV.fetch("AI_ENABLED", false)
  end

  def ai
    if user_signed_in?
      current_user.update(ai_enabled: !current_user.ai_enabled)
      referer = request.headers["Referer"]
      puts "referer: #{referer}"
      render json: { status: "success", ai_enabled: current_user.ai_enabled, redirect_to: referer }
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
end
