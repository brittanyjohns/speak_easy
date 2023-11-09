# == Schema Information
#
# Table name: images
#
#  id                   :bigint           not null, primary key
#  ai_generated         :boolean          default(FALSE)
#  audio_url            :string
#  category             :string
#  image_prompt         :string
#  image_url            :string
#  label                :string
#  private              :boolean          default(TRUE)
#  send_request_on_save :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#
class Image < ApplicationRecord
  belongs_to :user, optional: true
  has_many :board_images, dependent: :destroy
  has_many :response_images, dependent: :destroy
  attr_accessor :descriptive_prompt
  include ImageHelper
  include SpeechHelper

  validates :label, presence: true

  has_one_attached :saved_image
  has_one_attached :cropped_image

  after_create :generate_image, if: :send_request_on_save

  scope :public_images, -> { where(private: false) }
  # scope :with_attached_cropped_image, -> { with_attached_cropped_image }

  def display_image
    if cropped_image.attached?
      cropped_image
    else
      saved_image
    end
  end

  def generate_image
    self.send_request_on_save = false
    if self.saved_image.attached? || self.cropped_image.attached?
      puts "Image already has an image attached. Skipping..."
      self.save
    else
      self.create_image
    end
  end

  def self.searchable_images_for(user = nil)
    if user
      Image.where(private: false).or(Image.where(user_id: user.id))
    else
      Image.where(private: false)
    end
  end

  def name
    image_prompt || label
  end

  def speak_name
    label
  end

  def broadcast_upload
    broadcast_replace_to :image_list
  end

  def main_image_on_disk
    ActiveStorage::Blob.service.path_for(saved_image.key)
  end

  def prompt_to_send
    descriptive_prompt || "A simple clip art image of: #{label}"
  end

  def open_ai_opts
    { prompt: prompt_to_send }
  end

  def self.category_options
    [
      "Animals & Pets",
      "Family & People",
      "Play & Entertainment",
      "Food & Drink",
      "Places & Nature",
      "Colors & Shapes",
      "Feelings & Actions",
      "Things & Stuff",
    ]
  end

  def response_board
    ResponseBoard.find_by(name: label)
  end

  def existing_responses
    if response_board
      response_board.images.map(&:label)
    else
      []
    end
  end

  def continue_conversation?
    self.category == "Feelings & Actions"
  end

  def prompt_for_child_conversation
    # Begin the prompt with a clear and concise introduction
    prompt = "Imagine a person with special needs is using an AAC device to communicate. "
    prompt += "They are using a board of images to communicate and have chosen the image '#{label}'. "
    prompt += "They are now looking for the next word or phrase to communicate. "
    # prompt = "For the word '#{label}', suggest 2-3 words or short phrases most likely to be spoken next in a conversation. "
    # prompt += "If the word '#{label}' would most commonly be used to start a sentence, please suggest 2-3 words or short phrases most likely to be spoken next in a conversation. "
    prompt += "If the word '#{label}' would most commonly be used to end a sentence, please respond with the string 'end' only. Otherwise, "
    prompt += "please suggest 3-5 words or short phrases most likely to be spoken next in a conversation. With the last word being spoken was '#{label}'. "

    # Instruction for the desired format and constraints
    prompt += "Categorize each suggestion choosing from the following: #{Image.category_options.join(", ")}. "

    # prompt += "Each entry should be as concise as possible, favoring single words. "
    # prompt += "Keep in mind these words/phrases to populate an AAC board for a child with special needs to use to communicate so the responses are what is presented when they choose "

    # Guidance to avoid repetition and overly common words
    # prompt += "Avoid repetitions, and do not use generic words such as 'a', 'of', 'the', etc. "

    # Example of what the response should look like
    prompt += "Expected response format is an array of hashes ONLY. Example: \n"
    prompt += "[{ category: 'Family & People', label: 'mom' }, { category: 'Food & Drink', label: 'milk' }]"

    # Exclude previously used words, if any, with a clear instruction
    # if existing_responses.any?
    #   excluded = existing_responses.join(", ")
    #   prompt += "Do NOT include these words/phrases: #{excluded}.\n"
    # end

    # Return the constructed prompt
    prompt
  end

  def chat_with_ai(prompt = nil)
    response_board = ResponseBoard.find_by(name: self.label)
    if response_board && response_board.images.count > 25
      puts "Found response board for #{self.label} with id #{response_board.id}\n Skipping..."
      return response_board
    end

    prompt ||= prompt_for_child_conversation
    message = {
      "role": "user",
      "content": prompt,
    }
    begin
      ai_client = OpenAiClient.new({ messages: [message] })
      response = ai_client.create_chat
    rescue => e
      puts "**** ERROR **** \n#{e.message}\n"
    end
    if response && response[:role]
      role = response[:role] || "assistant"
      response_content = response[:content]

      puts "Role: #{role} \nContent: #{response_content}"
      if response_board
        response_board.create_images(response_content)
      else
        response_board = ResponseBoard.create(name: self.label).create_images(response_content)
      end
      response_board
    else
      puts "*** ERROR *** \nDid not receive valid response. Response: #{response}\n"
      Rails.logger.debug "*** ERROR *** \nDid not receive valid response. Response: #{response}\n"
    end
  end
end
