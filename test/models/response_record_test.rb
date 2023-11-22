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
require "test_helper"

class ResponseRecordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
