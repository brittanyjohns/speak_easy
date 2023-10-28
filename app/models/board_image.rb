# == Schema Information
#
# Table name: board_images
#
#  id         :bigint           not null, primary key
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  board_id   :bigint           not null
#  image_id   :bigint           not null
#
# Indexes
#
#  index_board_images_on_board_id  (board_id)
#  index_board_images_on_image_id  (image_id)
#
# Foreign Keys
#
#  fk_rails_...  (board_id => boards.id)
#  fk_rails_...  (image_id => images.id)
#
class BoardImage < ApplicationRecord
  belongs_to :board
  belongs_to :image
end
