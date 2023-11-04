class ApplicationController < ActionController::Base
  # before_action :authenticate_user!, :set_current_user, unless: :devise_controller?
  skip_before_action :verify_authenticity_token

  def set_current_user
    @current_user = current_user
  end

  def after_sign_in_path_for(resource)
    boards_path
  end
end
