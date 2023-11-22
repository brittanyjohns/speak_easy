# == Schema Information
#
# Table name: response_boards
#
#  id                         :bigint           not null, primary key
#  name                       :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  next_response_board_id     :integer
#  parent_id                  :integer
#  previous_response_board_id :integer
#
# Indexes
#
#  index_response_boards_on_next_response_board_id      (next_response_board_id)
#  index_response_boards_on_parent_id                   (parent_id)
#  index_response_boards_on_previous_response_board_id  (previous_response_board_id)
#
class ResponseBoard < ApplicationRecord
  has_many :response_records
  has_many :response_images, dependent: :destroy
  has_many :images, through: :response_images
  validates :name, presence: true
  normalizes :name, with: ->name { name.downcase }
  has_one :next_board, class_name: "ResponseBoard", foreign_key: "next_id"
  has_one :previous_board, class_name: "ResponseBoard", foreign_key: "previous_id"
  belongs_to :parent_board, class_name: "ResponseBoard", optional: true, foreign_key: "parent_id"

  CREATE_AI_IMAGES = ENV.fetch("CREATE_AI_IMAGES", "false") == "true"

  def response_options
    response_images.where.not(label: name)
  end

  def source_response_image
    ResponseImage.find_by(label: name)
  end

  def response_records
    ResponseRecord.where(name: name)
  end

  def create_images(response_content, word_list = nil, user_id = nil)
    pp response_content

    # response_content.gsub("[", "").gsub("]", "").gsub("'", "").split(", ").each do |content|
    array_of_hashes = eval(response_content)
    array_of_hashes.each do |content|
      if content.is_a?(String)
        label = content
        category = nil
      elsif content.is_a?(Hash)
        label = content["label"] || content[:label]
        category = content["category"] || content[:category]
      end
      puts "Label: #{label} - Category: #{category}"
      img = Image.find_by(label: label, private: false)
      puts "Found image: #{img.label}" if img

      unless img
        img = Image.create(label: label, send_request_on_save: CREATE_AI_IMAGES, private: false, category: category, ai_generated: CREATE_AI_IMAGES)
        puts "Created image: #{img.label}\n#{img.inspect}"
      else
        if category && img.category != category
          img.category = category
          img.send_request_on_save = false
          if img.save
            puts "Updated image category: #{img.label}"
          else
            puts "Error updating image category: #{img.label}"
          end
        end
      end

      if img
        # self.images << img unless self.images.include?(img)
        ri = ResponseImage.find_by(response_board_id: self.id, image_id: img.id, label: img.label)
        ri = ResponseImage.create(response_board_id: self.id, image_id: img.id, label: img.label) unless ri
        self.response_images << ri unless self.response_images.include?(ri)
      end
    end
    self
  end

  def create_response_record(word_list, user_id = nil, situation = nil)
    word_string = word_list.is_a?(Array) ? word_list.join(" ") : word_list
    throw "Word list is not a string" unless word_string.is_a?(String)
    response_record = self.response_records.find_or_create_by(word_list: word_string, user_id: user_id, name: self.name, word_array: [word_list].flatten, situation: situation)
    response_record.response_image_ids.concat(self.response_image_ids).uniq!
    response_record.save
  end
end
