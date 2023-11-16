# == Schema Information
#
# Table name: response_records
#
#  id                 :bigint           not null, primary key
#  name               :string
#  response_image_ids :integer          default([]), is an Array
#  word_list          :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer
#
require "test_helper"

class ResponseRecordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
