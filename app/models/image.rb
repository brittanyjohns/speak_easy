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
    self.create_image
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
    descriptive_prompt || label
  end

  def open_ai_opts
    { prompt: prompt_to_send }
  end

  def self.category_options
    ["TV Shows", "Food", "Animals", "People", "Places", "Things", "Actions", "Emotions",
     "Colors", "Numbers", "Letters", "Shapes", "Weather", "Time", "Sports", "Music",
     "Clothing", "Body Parts", "Vehicles", "Technology", "School", "Nature", "Holidays",
     "Family", "Household", "Jobs", "Other"]
  end

  def source_response_board
    ResponseBoard.where(name: label).first
  end

  def existing_responses
    if source_response_board
      source_response_board.images.map(&:label)
    else
      []
    end
  end

  def prompt_for_child_conversation
    prompt = "Given the word '#{label}', what are the most likely words to come next in a conversation for a child using AAC? Return an array of 4-6 strings only. Keep them to as few words as possible. 3 words max. A single word is highly preferred. Do not repeat words and avoid common single words like 'a', 'of', 'the', etc. Expected example response: \n['a list of',  'words', 'formatted', 'like this']\n"
    prompt += "Exclude the following words from your response: \n#{existing_responses.join(", ")}\n" if existing_responses.any?
    prompt
  end

  def chat_with_ai(prompt = nil)
    response_board = ResponseBoard.find_by(name: self.label)
    if response_board && response_board.images.count > 10
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
