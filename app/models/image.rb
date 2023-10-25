# == Schema Information
#
# Table name: images
#
#  id                   :integer          not null, primary key
#  audio_url            :string
#  image_url            :string
#  label                :string
#  send_request_on_save :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class Image < ApplicationRecord
  attr_accessor :descriptive_prompt
  include ImageHelper
  include SpeechHelper

  has_one_attached :saved_image

  after_create :generate_image, if: :send_request_on_save

  validates :label, presence: true

  def generate_image
    puts "Generating image for #{self.label}"
    self.create_image
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

  def label_prompt
    "Generate an image that clearly represents the concept of '#{label}'. The image should be a photograph of a real object, not a drawing or painting. The image should be a photograph of a single object, not a group of objects."
  end

  def prompt_to_send
    descriptive_prompt || label
  end

  def open_ai_opts
    { prompt: prompt_to_send }
  end
end
