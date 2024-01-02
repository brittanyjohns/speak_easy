# == Schema Information
#
# Table name: docs
#
#  id                :bigint           not null, primary key
#  documentable_type :string           not null
#  image_description :text
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  documentable_id   :bigint           not null
#
# Indexes
#
#  index_docs_on_documentable  (documentable_type,documentable_id)
#
class Doc < ApplicationRecord
  belongs_to :documentable, polymorphic: true
  has_one_attached :image
  has_many :boards
  # has_one :board
  has_many :images, through: :boards

  include ImageHelper

  # before_create :save_raw_text
  after_create :enhance_image_description

  def current_board
    boards.last
  end

  def save_raw_text
    self.raw_text = self.image_description
  end

  def image_name
    name.blank? ? documentable.name : name
  end

  def create_board_from_image
    board = Board.new
    board.doc = self
    board.name = self.name || "Board for Doc #{id}"
    board.save!
    create_images_from_description(board)
    board
  end

  def create_images_from_description(board)
    puts "**** create_images_from_description **** \n"
    json_description = JSON.parse(image_description)
    json_description["food"].each do |food|
      puts "food: #{food}\n"
      item_name = menu_item_name(food["name"])
      puts "Finding or creating image for #{item_name}\n"
      image = Image.find_or_create_by!(label: item_name)
      image.label = item_name
      unless food["image_description"].blank?
        image.image_prompt = food["image_description"]
      else
        image.image_prompt = "Create an image of #{item_name}"
        image.image_prompt += " with #{food["description"]}" if food["description"]
      end
      puts "\n\n\n***image.image_prompt: #{image.image_prompt}\n"
      # image.send_request_on_save = true
      # image.private = false
      image.save!
      board.add_image(image.id)
      image.start_generate_image_job unless image.display_image.attached?
    end
  end

  def menu_item_name(item_name)
    item_name.downcase!
    # Strip out any non-alphanumeric characters
    item_name.gsub(/[^a-z ]/i, '')
    puts "item_name: #{item_name}\n"
    item_name
  end



  def enhance_image_description
    # return unless image_description
    puts "Image description before: #{image_description}\n raw_text: #{raw_text}\n"

    if !raw_text.blank?
      self.image_description = clarify_image_description
      puts "Image description after: #{image_description}\n"
      puts "**** ERROR **** \nNo image description provided.\n" unless image_description
      self.save!
      create_board_from_image
    else
      puts "Image description invaild: #{image_description}\n"
      image_description
    end
  end

  def external_image_url
    self.image.representation(resize_to_limit: [100, 100]).processed.url
  end

  def proxy_image_url
    rails_storage_proxy_path(image)
  end

  def main_image_on_disk
    throw "No image attached to Doc #{id}" unless image.attached?
    external_image_url
  end

  def image_path
    image_path = image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true) : nil
    puts "image_path: #{image_path}"
    image_path
  end

  def open_ai_opts
    { prompt: prompt_to_send }
  end

  def prompt_to_send
    description_prompt
  end

  def description_prompt
    "Please describe the food and drink options on this kid's restaurant menu."
  end
end
