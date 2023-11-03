# == Schema Information
#
# Table name: images
#
#  id                   :bigint           not null, primary key
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
  default_scope { with_attached_cropped_image }
  belongs_to :user, optional: true
  has_many :board_images, dependent: :destroy
  attr_accessor :descriptive_prompt
  include ImageHelper
  include SpeechHelper

  validates :label, presence: true

  has_one_attached :saved_image
  has_one_attached :cropped_image

  after_create :generate_image, if: :send_request_on_save

  scope :public_images, -> { where(private: false) }

  def display_image
    if cropped_image.attached?
      cropped_image
    else
      saved_image
    end
  end

  def generate_image
    puts "Generating image for #{self.label}"
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
end
