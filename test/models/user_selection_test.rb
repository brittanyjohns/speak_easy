# == Schema Information
#
# Table name: user_selections
#
#  id         :bigint           not null, primary key
#  current    :boolean          default(TRUE)
#  words      :string           default([]), is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_selections_on_user_id  (user_id)
#  index_user_selections_on_words    (words) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class UserSelectionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
