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
require "test_helper"

class ResponseBoardTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
