# == Schema Information
#
# Table name: images
#
#  id                   :bigint           not null, primary key
#  audio_url            :string
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
  attr_accessor :descriptive_prompt
  include ImageHelper
  include SpeechHelper

  validates :label, presence: true

  has_one_attached :saved_image do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [100, 100]
    attachable.variant :small, resize_to_limit: [200, 200]
    attachable.variant :medium, resize_to_limit: [300, 300]
    attachable.variant :large, resize_to_limit: [500, 500]
  end
  has_one_attached :audio_clip

  after_create :generate_image, if: :send_request_on_save

  scope :public_images, -> { where(private: false) }

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
end
