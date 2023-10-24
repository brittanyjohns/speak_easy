# == Schema Information
#
# Table name: images
#
#  id                   :integer          not null, primary key
#  audio_url            :string
#  image_url            :string
#  label                :string
#  send_request_on_save :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
require "test_helper"

class ImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
