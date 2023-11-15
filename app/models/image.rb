# == Schema Information
#
# Table name: images
#
#  id                   :bigint           not null, primary key
#  ai_generated         :boolean          default(FALSE)
#  audio_url            :string
#  category             :string
#  final_response_count :integer          default(0)
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

  after_save :generate_image, if: :send_request_on_save

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
    else
      self.create_image
    end
    self.save
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
    # prompt = "Imagine a person with special needs is using an AAC device to communicate. "
    # prompt += "They are using a board of images to communicate and have chosen the image '#{label}'. "
    # prompt += "They are now looking for the next word or phrase to communicate. "
    prompt += "If the word '#{label}' would most commonly be used to end a sentence, please respond with the string 'end' only. Otherwise, "
    prompt += "please suggest 3-5 words or short phrases most likely to be spoken next in a conversation. With the last word being spoken was '#{label}'. "

    # Instruction for the desired format and constraints
    prompt += "Categorize each suggestion choosing from the following: #{Image.category_options.join(", ")}. "
    prompt += "Expected response format is an array of hashes ONLY. Example: \n"
    prompt += "[{ category: 'Family & People', label: 'mom' }, { category: 'Food & Drink', label: 'milk' }]"

    # prompt += "Each entry should be as concise as possible, favoring single words. "
    # prompt += "Keep in mind these words/phrases to populate an AAC board for a child with special needs to use to communicate so the responses are what is presented when they choose "

    # Guidance to avoid repetition and overly common words
    # prompt += "Avoid repetitions, and do not use generic words such as 'a', 'of', 'the', etc. "

    # Example of what the response should look like

    # Exclude previously used words, if any, with a clear instruction
    # if existing_responses.any?
    #   excluded = existing_responses.join(", ")
    #   prompt += "Do NOT include these words/phrases: #{excluded}.\n"
    # end

    # Return the constructed prompt
    prompt
  end

  def assistant_prompt
    {
      "role": "assistant",
      "content": "A person with special needs is using an AAC device to communicate. You will predict the next word or phrase to communicate."
    }
  end

  def setup_prompt
    {
      "role": "user",
      "content": "I'm going to give you a list of words or short phrases (that represents a sentence being formed) and I want you to return an array of 3-5 options for the next word or phase (limit to 3 words max). 
      Return ONLY an array of strings. 
      Example 1 - Given the word list ['I'], you return ['want', 'need', 'am', 'see', 'hear', 'know']. 
      Example 2 - Given the word list ['I', 'want'], you return ['pizza', 'water', 'milk', 'juice', 'food'].
      If the word(s) I give you is most likely make a complete sentence, please return the string 'end' only.
      Example 1 - Given the word list ['I', 'want', 'pizza', 'please'] you return ['end'].
      If the word(s) I give you is most likely make a question or request, please return the string 'question' only.
      Example 2 - Given the word list ['Can', 'I', 'have', 'some', 'water'] you return ['please'].",

    }
  end

  def chat_with_ai(prompt = nil, response_image_id = nil)
    response_board = ResponseBoard.find_by(name: self.label)
    if response_board && response_board.images.count > 30
      puts "Found response board for #{self.label} with id #{response_board.id}\n Skipping..."
      return response_board
    end

    prompt ||= prompt_for_child_conversation

    puts "Prompt: #{prompt}"

    message = {
      "role": "user",
      "content": prompt,
    }
    begin
      ai_client = OpenAiClient.new({ messages: [assistant_prompt, setup_prompt, message] })
      response = ai_client.create_chat
      Rails.logger.debug "\n\nResponse: #{response}\n\n"
    rescue => e
      puts "**** ERROR **** \n#{e.message}\n"
    end
    if response && response[:role]
      role = response[:role] || "assistant"
      response_content = response[:content]

      puts "Role: #{role} \nContent: #{response_content}"
      if response_content.include?("end")
        puts "Response content includes end"
        self.final_response_count += 1
        self.save
        response_image = ResponseImage.find(response_image_id)
        test_response_image = self.response_images.find_by(response_board_id: response_board.id)
        if test_response_image
          puts "Found response image: #{test_response_image.id}"
          puts "Response board: #{response_board.id}"
        end
        response_image.final_response = true
        response_image.save
      end

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
