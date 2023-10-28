# == Schema Information
#
# Table name: images
#
#  id                   :bigint           not null, primary key
#  audio_url            :string
#  image_prompt         :string
#  image_url            :string
#  label                :string
#  private              :boolean          default(TRUE)
#  send_request_on_save :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#
require "test_helper"

class ImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
