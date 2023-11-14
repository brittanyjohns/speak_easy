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
    # Image.where(label: name).first
    Image.find_or_create_by(label: name, private: false)
  end

  def create_images(response_content)
    puts "Response content is not an array - #{response_content.class}"
    pp response_content

    # response_content.gsub("[", "").gsub("]", "").gsub("'", "").split(", ").each do |content|
    array_of_hashes = eval(response_content)
    puts "Array of hashes: #{array_of_hashes} - #{array_of_hashes.class}"
    array_of_hashes.each do |content|
      puts "Content: #{content} - #{content.class}"
      if content.is_a?(String)
        puts "Content is a string"
        label = content
        category = "None"
      elsif content.is_a?(Hash)
        puts "Content is a hash"
        label = content["label"] || content[:label]
        category = content["category"] || content[:category]
      end
      puts "Label: #{label} - Category: #{category}"
      img = Image.find_by(label: label)
      puts "Found image: #{img.label}" if img

      unless img
        create_ai_image = true
        img = Image.create(label: label, send_request_on_save: create_ai_image, private: false, category: category, ai_generated: create_ai_image)
        puts "Created image: #{img.label}"
      else
        if category && img.category != category
          img.category = category
          if img.save
            puts "Updated image category: #{img.label}"
          else
            puts "Error updating image category: #{img.label}"
          end
        end
      end

      if img
        self.images << img unless self.images.include?(img)
        if content.include?("end")
          puts "Response content includes end"
          source_image.final_response_count += 1
          source_image.save
          response_image = self.response_images.find_by(image_id: img.id)
          response_image.final_response = true
          response_image.save
        end
      end
    end
    self
  end
end
