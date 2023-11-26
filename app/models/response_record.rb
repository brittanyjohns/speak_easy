# == Schema Information
#
# Table name: response_records
#
#  id                 :bigint           not null, primary key
#  name               :string
#  response_image_ids :integer          default([]), is an Array
#  situation          :string
#  word_array         :string           default([]), is an Array
#  word_list          :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  response_board_id  :integer
#  user_id            :integer
#
# Indexes
#
#  index_response_records_on_response_board_id  (response_board_id)
#  index_response_records_on_word_array         (word_array) USING gin
#
class ResponseRecord < ApplicationRecord
  normalizes :name, with: ->name { name.downcase }
  normalizes :word_list, with: ->word_list { word_list.downcase }

  def response_images
    ResponseImage.where(id: self.response_image_ids)
  end

  def remaining_images
    ResponseImage.where.not(id: self.response_image_ids)
  end

  def response_labels
    response_images.map(&:label)
  end

  # def response_board
  #   ResponseBoard.find_or_create_by(name: self.name)
  # end

  def response_board
    ResponseBoard.find_or_create_by(name: self.word_list)
  end
end
