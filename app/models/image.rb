# == Schema Information
#
# Table name: images
#
#  id                   :bigint           not null, primary key
#  ai_generated         :boolean          default(FALSE)
#  ai_prompt            :text
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
  attr_accessor :situation
  include ImageHelper

  validates :label, presence: true
  normalizes :label, with: ->label { label.downcase }

  has_one_attached :saved_image
  has_one_attached :cropped_image

  after_save :generate_image, if: :send_request_on_save
  after_create_commit :broadcast_upload

  def ensure_response_board
    response_board = ResponseBoard.find_or_create_by(name: self.label)
    self.response_images.find_or_create_by(response_board_id: response_board.id, label: self.label)
  end

  scope :public_images, -> { where(private: false) }

  def display_image
    if cropped_image.attached?
      cropped_image
    else
      saved_image
    end
  end

  def generate_image
    puts "Generate Image: #{label}"
    self.send_request_on_save = false

    if self.saved_image.attached? || self.cropped_image.attached?
      puts "Image already has an image attached. Skipping..."
    else
      self.create_image
      self.ai_generated = true
    end
    self.save
  end

  def is_new_image?
    created_at > 3.minutes.ago
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
    Rails.logger.info "Image: #{id}  #{label} broadcasted"
  end

  def main_image_on_disk
    ActiveStorage::Blob.service.path_for(saved_image.key)
  end

  def prompt_to_send
    image_prompt || gpt_prompt
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

  # >>> For Future Use

  # def prompt_for_child_conversation
  #   prompt += "If the word '#{label}' would most commonly be used to end a sentence, please respond with the string 'end' only. Otherwise, "
  #   prompt += "please suggest 3-5 words or short phrases most likely to be spoken next in a conversation. With the last word being spoken was '#{label}'. "

  #   # Instruction for the desired format and constraints
  #   prompt += "Categorize each suggestion choosing from the following: #{Image.category_options.join(", ")}. "
  #   prompt += "Expected response format is an array of hashes ONLY. Example: \n"
  #   prompt += "[{ category: 'Family & People', label: 'mom' }, { category: 'Food & Drink', label: 'milk' }]"

  #   # Exclude previously used words, if any, with a clear instruction
  #   # if existing_responses.any?
  #   #   excluded = existing_responses.join(", ")
  #   #   prompt += "Do NOT include these words/phrases: #{excluded}.\n"
  #   # end

  #   # Return the constructed prompt
  #   prompt
  # end

  def self.situation_list
    ["at home", "at school", "at the park", "at the store", "at the doctor's office", "at the dentist's office", "at the hospital", "at the library", "at the beach", "at the pool", "at the gym", "at the zoo", "at the museum", "at the movies", "at the restaurant", "at the mall", "at the airport", "at the train station", "at the bus station", "at the gas station", "at the grocery store", "at the post office", "at the bank", "at the pharmacy", "at the doctor's office", "at the dentist's office", "at the hospital", "at the library", "at the beach", "at the pool", "at the gym", "at the zoo", "at the museum", "at the movies", "at the restaurant", "at the mall", "at the airport", "at the train station", "at the bus station", "at the gas station", "at the grocery store", "at the post office", "at the bank", "at the pharmacy"].sample
  end

  # def situation_location
  #   self.situation || Image.situation_list.sample
  # end

  def situation_prompt(situation_location)
    "Use the given situation to predict the next word or phrase to communicate. The situation is: #{situation_location}"
  end

  def setup_prompt
    content = "A person with special needs is using an AAC device to communicate. 
    You will predict the next word or phrase to communicate. I'm going to give you a list of words or short phrases (that represents a sentence being formed) and I want you to return an array of 2-3 options for the next word or phase (limit to 5 words max). 
    Return ONLY an array of strings. The array should be in order of most likely to least likely & be limited to 5 words max.
    # Example 1 - Given the word list ['I'], you return ['want', 'need', 'am', 'see', 'hear', 'know'].
    # Example 2 - Given the word list ['I', 'want'], you return ['pizza', 'water', 'milk'].
    If the word(s) I give you is most likely make a complete sentence, please return ['end'] only.
    Example 1 - Given the word list ['I', 'want', 'pizza', 'please'] you return ['end']."
    # If the word(s) I give you is most likely make a question or request, please return the string 'question' only.
    # Example 2 - Given the word list ['Can', 'I', 'have', 'some', 'water'] you return ['please'].",

    if existing_responses.any?
      excluded = existing_responses.join(", ")
      content += "Do NOT include these words/phrases: #{excluded}.\n"
    end
    content += "If there are no more words to add to the sentence (without repeating), please return the string ['end'] only."
    {
      "role": "user",
      "content": content,
    }
  end

  def response_record_for(user_id)
    ResponseRecord.find_by(name: label, user_id: user_id)
  end

  def situation_message(situation)
    {
      "role": "user",
      "content": "Please keep in mind the situation is: #{situation}. Use this to help you predict the next word or phrase to communicate.",
    }
  end

  def chat_with_ai(prompt = nil, response_image_id = nil, word_list = nil, user_id = nil)
    Rails.logger.debug "\n\nChat with AI for #{self.label}\n\n"
    response_board = ResponseBoard.find_by(name: self.label)
    if response_board && response_board.images.count > 30
      puts "Found response board for #{self.label} with id #{response_board.id}\n Skipping..."
      return response_board
    end

    prompt ||= prompt_for_child_conversation

    message = {
      "role": "user",
      "content": prompt,
    }
    messages_to_send = [setup_prompt]
    situation = nil
    if user_id
      user = User.find(user_id)
      if user
        puts "User: #{user.id} #{user.name}"
        situation = user.current_situation
      end
    end
    unless situation.blank?
      puts "Situation: #{situation}"
      messages_to_send << situation_message(situation)
    end
    messages_to_send << message
    puts "Messages to send: #{messages_to_send.count}"
    # debugger
    begin
      ai_client = OpenAiClient.new({ messages: messages_to_send })
      response = ai_client.create_chat
      Rails.logger.debug "\n\nResponse: #{response}\n\n"
    rescue => e
      puts "**** ERROR **** \n#{e.message}\n"
    end
    if response && response[:role]
      role = response[:role] || "assistant"
      response_content = response[:content]

      if response_content.include?("end")
        puts "Response content includes end"
        self.final_response_count += 1
        self.save
        response_image = ResponseImage.find(response_image_id)

        response_image.final_response = true
        response_image.save
      end

      if response_board
        response_board.create_images(response_content, word_list, user_id)
      else
        response_board = ResponseBoard.create(name: self.label).create_images(response_content, word_list, user_id)
      end
      response_board
    else
      puts "*** ERROR *** \nDid not receive valid response. Response: #{response}\n"
      Rails.logger.debug "*** ERROR *** \nDid not receive valid response. Response: #{response}\n"
    end
  end
end
