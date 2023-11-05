class ResponseImagesController < ApplicationController
  def click
    if params[:id].present?
      @response_image = ResponseImage.find(params[:id])
      @response_image.click_count += 1
      @response_image.save
    end
  end
end
