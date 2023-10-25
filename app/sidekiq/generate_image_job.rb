class GenerateImageJob
  include Sidekiq::Job

  def perform(*args)
    image_id = args[0]
    image = Image.find(image_id)
    image.create_image
    img_path = Rails.application.routes.url_helpers.rails_blob_path(image.saved_image, only_path: true)
    image.image_url = img_path
    image.save
    puts "GenerateImageJob: #{image_id} saved. #{img_path}"

    Rails.logger.info "GenerateImageJob: #{image_id}"
    image.broadcast_upload
    Rails.logger.info "GenerateImageJob: #{image_id} broadcasted"
    # Do something
  end
end
