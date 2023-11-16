# == Schema Information
#
# Table name: response_records
#
#  id         :bigint           not null, primary key
#  name       :string
#  word_list  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ResponseRecord < ApplicationRecord
  def response_images
    ResponseImage.find(self.response_image_ids)
  end

  def remaining_images
    ResponseImage.where.not(id: self.response_image_ids)
  end

  # def response_board
  #   ResponseBoard.find_or_create_by(name: self.name)
  # end

  def response_board
    ResponseBoard.find_or_create_by(name: self.word_list)
  end
end
