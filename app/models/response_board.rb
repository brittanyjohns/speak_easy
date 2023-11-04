# == Schema Information
#
# Table name: response_boards
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ResponseBoard < ApplicationRecord
  has_many :response_images, dependent: :destroy
  has_many :images, through: :response_images

  def source_image
    Image.where(label: name).first
  end

  def create_images(response_content)
    if response_content.is_a?(Array)
      response_content.each do |content|
        img = Image.find(label: content)
        unless img
          img = Image.create(label: content, send_request_on_save: true, private: false)
          puts "Created image: #{img.label}"
        end
        self.images << img unless self.images.include?(img)
      end
    else
      response_content.gsub("[", "").gsub("]", "").gsub("'", "").split(",").each do |content|
        img = Image.find_by(label: content.strip)
        unless img
          img = Image.create(label: content.strip, send_request_on_save: true, private: false)
          puts "Created image: #{img.label}"
        end
        self.images << img unless self.images.include?(img)
      end
      pp response_content
    end
    self
  end
end
