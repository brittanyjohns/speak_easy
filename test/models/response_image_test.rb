# == Schema Information
#
# Table name: response_images
#
#  id                :bigint           not null, primary key
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
require "test_helper"

class ResponseImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
