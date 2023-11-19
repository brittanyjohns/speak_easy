class GenerateImageJob
  include Sidekiq::Job
  sidekiq_options queue: "default", retry: 1, backtrace: true

  def perform(*args)
    image_id = args[0]
    image = Image.find(image_id)
    # image.update(send_request_on_save: true)
    image.generate_image
    # img_path = Rails.application.routes.url_helpers.rails_blob_path(image.saved_image, only_path: true)
    # image.image_url = img_path
    # image.save

    Rails.logger.info "GenerateImageJob: #{image_id}"
  end
end
