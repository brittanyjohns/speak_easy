class ApplicationController < ActionController::Base
  # before_action :authenticate_user!, :set_current_user, unless: :devise_controller?
  skip_before_action :verify_authenticity_token

  def set_current_user
    @current_user = current_user
  end

  def resubmit(item_to_save)
    item_path = public_send("#{item_to_save.class.to_s.downcase}_url", item_to_save)
    item_to_save.descriptive_prompt = params[:descriptive_prompt]
    resubmit_success = item_to_save.create_image
    respond_to do |format|
      if resubmit_success
        format.html { redirect_to item_path }
        format.json { render :show, status: :created, location: item_to_save }
      else
        format.html { render item_path, status: :unprocessable_entity }
        format.json { render json: item_to_save.errors, status: :unprocessable_entity }
      end
    end
  end
end
