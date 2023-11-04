class AskAiJob
  include Sidekiq::Job
  sidekiq_options queue: "default", retry: 2, backtrace: true

  def perform(image_id)
    puts
    Rails.logger.debug "\n*** Running the Ask AI job!! IMAGE ID: #{image_id}\n"
    begin
      image = Image.find(image_id)
      image.chat_with_ai
    rescue => e
      Rails.logger.debug "ERROR: #{e.message}"
      Rails.logger.debug e.backtrace
    end
  end
end
