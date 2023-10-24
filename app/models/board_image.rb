# == Schema Information
#
# Table name: board_images
#
#  id         :integer          not null, primary key
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  board_id   :integer          not null
#  image_id   :integer          not null
#
# Indexes
#
#  index_board_images_on_board_id  (board_id)
#  index_board_images_on_image_id  (image_id)
#
# Foreign Keys
#
#  board_id  (board_id => boards.id)
#  image_id  (image_id => images.id)
#
class BoardImage < ApplicationRecord
  belongs_to :board
  belongs_to :image
end
