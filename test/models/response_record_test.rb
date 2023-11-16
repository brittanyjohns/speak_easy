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
require "test_helper"

class ResponseRecordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
