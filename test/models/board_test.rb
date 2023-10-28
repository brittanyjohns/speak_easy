# == Schema Information
#
# Table name: boards
#
#  id          :bigint           not null, primary key
#  grid_size   :string
#  name        :string
#  show_labels :boolean
#  theme_color :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_boards_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class BoardTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
