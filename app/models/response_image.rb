# == Schema Information
#
# Table name: response_images
#
#  id                :bigint           not null, primary key
#  click_count       :integer          default(0)
#  final_response    :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  image_id          :bigint           not null
#  response_board_id :bigint           not null
#
# Indexes
#
#  index_response_images_on_image_id           (image_id)
#  index_response_images_on_response_board_id  (response_board_id)
#
# Foreign Keys
#
#  fk_rails_...  (image_id => images.id)
#  fk_rails_...  (response_board_id => response_boards.id)
#
class ResponseImage < ApplicationRecord
  belongs_to :response_board
  belongs_to :image
  broadcasts_to ->(response_image) { :response_image_list }, inserts_by: :prepend, target: "response_image_list"

  def label
    image.label
  end

  def source_board
    ResponseBoard.find_or_create_by(name: label)
  end
end
