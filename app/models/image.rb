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

  scope :without_attached_saved_image, -> { left_joins(:saved_image_attachment).where("active_storage_attachments.id IS NULL") }

  after_save :generate_image, if: :send_request_on_save
  after_create_commit :broadcast_upload

  def ensure_response_board
    response_board = ResponseBoard.find_or_create_by(name: self.label)
    self.response_images.find_or_create_by(response_board_id: response_board.id, label: self.label)
  end

  def external_image_url
    # Rails.application.routes.url_helpers.rails_blob_path(self.display_image)
    # Rails.application.routes.url_helpers.url_for(self.display_image)
    self.display_image.representation(resize_to_limit: [100, 100]).processed.url
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

  def id_and_label
    "#{id} - #{label}"
  end

  def self.searchable_images_for(user = nil)
    if user
      Image.where(private: false).or(Image.where(user_id: user.id)).or(Image.where(user_id: nil, private: false))
    else
      Image.where(private: false).or(Image.where(user_id: nil, private: false))
    end
  end

  def generate_description
    img_url = external_image_url
    puts "describe: #{img_url}"
    if self.saved_image.attached?
      response = OpenAiClient.describe_image(img_url)
      if response
        puts "Response: #{response}"
        self.ai_prompt = response
        self.save if self.ai_prompt
      else
        puts "**** ERROR **** \nDid not receive valid response. Response: #{response}\n"
      end
    else
      puts "Image does not have an image attached. Skipping..."
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
    return name unless ResponseBoard::CREATE_AI_IMAGES
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

  def chat_with_ai(prompt, response_image_id = nil, word_list = nil, user_id = nil)
    Rails.logger.debug "\n\nChat with AI for #{self.label}\n\n"
    response_board = ResponseBoard.find_by(name: self.label)
    if response_board && response_board.images.count > 30
      puts "Found response board for #{self.label} with id #{response_board.id}\n Skipping..."
      return response_board
    end
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

  def self.run_image_setup
    categorized_word_list = [
      { "category": "Food & Drink", "label": "hamburger" },
      { "category": "Feelings & Actions", "label": "to sleep" },
      { "category": "Food & Drink", "label": "sandwich" },
      { "category": "Food & Drink", "label": "apple" },
      { "category": "Food & Drink", "label": "cookie" },
      { "category": "Food & Drink", "label": "chicken" },
      { "category": "Food & Drink", "label": "crackers" },
      { "category": "Feelings & Actions", "label": "to talk" },
      { "category": "Food & Drink", "label": "chocolate" },
      { "category": "Things & Stuff", "label": "my book" },
      { "category": "Food & Drink", "label": "milk" },
      { "category": "Feelings & Actions", "label": "more" },
      { "category": "Feelings & Actions", "label": "please" },
      { "category": "Feelings & Actions", "label": "bake" },
      { "category": "Things & Stuff", "label": "toilet" },
      { "category": "Food & Drink", "label": "water" },
      { "category": "Family & People", "label": "a friend" },
      { "category": "Food & Drink", "label": "food" },
      { "category": "Food & Drink", "label": "sweet" },
      { "category": "Food & Drink", "label": "medicine" },
      { "category": "Feelings & Actions", "label": "is" },
      { "category": "Feelings & Actions", "label": "yum" },
      { "category": "Food & Drink", "label": "meal" },
      { "category": "Feelings & Actions", "label": "eat" },
      { "category": "Feelings & Actions", "label": "want" },
      { "category": "Feelings & Actions", "label": "good" },
      { "category": "Feelings & Actions", "label": "bite" },
      { "category": "Feelings & Actions", "label": "hungry" },
      { "category": "Feelings & Actions", "label": "full" },
      { "category": "Feelings & Actions", "label": "is fun" },
      { "category": "Food & Drink", "label": "snack" },
      { "category": "Feelings & Actions", "label": "chew" },
      { "category": "Food & Drink", "label": "pizza" },
      { "category": "Feelings & Actions", "label": "swallow" },
      { "category": "Feelings & Actions", "label": "swim" },
      { "category": "Feelings & Actions", "label": "taste" },
      { "category": "Play & Entertainment", "label": "I play" },
      { "category": "Food & Drink", "label": "plate" },
      { "category": "Food & Drink", "label": "dish" },
      { "category": "Food & Drink", "label": "juice" },
      { "category": "Food & Drink", "label": "dinner" },
      { "category": "Feelings & Actions", "label": "it moves" },
      { "category": "Food & Drink", "label": "lunch" },
      { "category": "Feelings & Actions", "label": "I need" },
      { "category": "Feelings & Actions", "label": "to go" },
      { "category": "Play & Entertainment", "label": "to play" },
      { "category": "Things & Stuff", "label": "my toy" },
      { "category": "Feelings & Actions", "label": "a hug" },
      { "category": "Colors & Shapes", "label": "colors are" },
      { "category": "Feelings & Actions", "label": "a break" },
      { "category": "Feelings & Actions", "label": "a turn" },
      { "category": "Feelings & Actions", "label": "it makes" },
      { "category": "Feelings & Actions", "label": "I want" },
      { "category": "Food & Drink", "label": "soda" },
      { "category": "Feelings & Actions", "label": "to eat" },
      { "category": "Play & Entertainment", "label": "to watch" },
      { "category": "Food & Drink", "label": "to drink" },
      { "category": "Food & Drink", "label": "tea" },
      { "category": "Feelings & Actions", "label": "to read" },
      { "category": "Feelings & Actions", "label": "to learn" },
      { "category": "Food & Drink", "label": "straw" },
      { "category": "Feelings & Actions", "label": "to see" },
      { "category": "Food & Drink", "label": "coffee" },
      { "category": "Food & Drink", "label": "drink" },
      { "category": "Feelings & Actions", "label": "thirsty" },
      { "category": "Food & Drink", "label": "bottle" },
      { "category": "Food & Drink", "label": "cup" },
      { "category": "Feelings & Actions", "label": "it" },
      { "category": "Places & Nature", "label": "ocean" },
      { "category": "Food & Drink", "label": "sippy" },
      { "category": "Feelings & Actions", "label": "splash" },
      { "category": "Feelings & Actions", "label": "thirst" },
      { "category": "Family & People", "label": "I" },
      { "category": "Feelings & Actions", "label": "to" },
      { "category": "Family & People", "label": "me" },
      { "category": "Feelings & Actions", "label": "some" },
      { "category": "Feelings & Actions", "label": "that" },
      { "category": "Family & People", "label": "you" },
      { "category": "Feelings & Actions", "label": "can" },
      { "category": "Feelings & Actions", "label": "now" },
      { "category": "Play & Entertainment", "label": "play" },
      { "category": "Feelings & Actions", "label": "do" },
      { "category": "Feelings & Actions", "label": "go" },
      { "category": "Food & Drink", "label": "fruit" },
      { "category": "Feelings & Actions", "label": "like" },
      { "category": "Feelings & Actions", "label": "am" },
      { "category": "Feelings & Actions", "label": "see" },
      { "category": "Feelings & Actions", "label": "have" },
      { "category": "Feelings & Actions", "label": "need" },
      { "category": "Feelings & Actions", "label": "feel" },
      { "category": "Feelings & Actions", "label": "think" },
      { "category": "Feelings & Actions", "label": "hello" },
      { "category": "Food & Drink", "label": "a snack" },
      { "category": "Things & Stuff", "label": "my iPad" },
      { "category": "Places & Nature", "label": "outside" },
      { "category": "Food & Drink", "label": "a drink" },
      { "category": "Feelings & Actions", "label": "I love it" },
      { "category": "Things & Stuff", "label": "its mine" },
      { "category": "Things & Stuff", "label": "its new" },
      { "category": "Feelings & Actions", "label": "I share it" },
      { "category": "Things & Stuff", "label": "desk" },
    ]

    categorized_word_list.each do |content|
      label = content[:label] || content["label"]
      category = content[:category] || content["category"]
      puts "Label: #{label} - Category: #{category}"
      img = self.find_by(label: label, private: false)
      puts "Found image #{img.id}: #{img.label} - #{img.category}" if img
      unless img
        img = self.create(label: label, send_request_on_save: ResponseBoard::CREATE_AI_IMAGES, private: false, category: category, ai_generated: ResponseBoard::CREATE_AI_IMAGES)
        puts "#{img.id} Created image: #{img.label}"
      else
        if category && img.category != category
          img.category = category
          if img.save
            puts "#{img.id} Updated image: #{img.label} - #{img.category}"
          end
        end
      end
    end
    puts "Done"
  end
end
