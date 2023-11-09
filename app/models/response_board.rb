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
    puts "Response content is not an array - #{response_content.class}"
    pp response_content
    if response_content.include?("end")
      puts "Response content includes end"
      return self
    end

    # response_content.gsub("[", "").gsub("]", "").gsub("'", "").split(", ").each do |content|
    array_of_hashes = eval(response_content)
    array_of_hashes.each do |content|
      label = content["label"] || content[:label]
      category = content["category"] || content[:category]
      next unless label && category
      puts "Label: #{label} - Category: #{category}"
      img = Image.find_by(label: label)
      unless img
        create_ai_image = false
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
        self.images << img unless self.images.include?(img)
        response_image = self.response_images.find_by(image_id: img.id)
        response_image.click_count += 1
        response_image.save
      end
    end
    self
  end
end
