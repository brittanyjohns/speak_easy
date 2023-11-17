class AskAiJob
  include Sidekiq::Job
  sidekiq_options queue: "default", retry: 1, backtrace: true

  def perform(image_id, response_image_id, word_list = nil, user_id = nil)
    Rails.logger.debug "\n*** Running the Ask AI job!! IMAGE ID: #{image_id}\n WORD LIST: #{word_list}\n"
    begin
      image = Image.find(image_id)
      if !word_list.blank?
        image.chat_with_ai("The word/phrase list is #{word_list}", response_image_id, word_list, user_id) if response_image_id
        image.chat_with_ai("The word/phrase list is #{word_list}") unless response_image_id
      else
        image.chat_with_ai("The word/phrase is '#{image.label}'", response_image_id, word_list) if response_image_id
        image.chat_with_ai("The word/phrase is '#{image.label}'") unless response_image_id
      end
    rescue => e
      Rails.logger.debug "ERROR: #{e.message}"
      Rails.logger.debug e.backtrace
    end
  end
end
