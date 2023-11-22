class ImageSetupJob
  include Sidekiq::Job

  def perform
    Rails.logger.info "Image Setup Job: Creating images? #{ResponseBoard::CREATE_AI_IMAGES}"
    Image.run_image_setup
    Rails.logger.info "Image Setup Job Complete"
  end
end
