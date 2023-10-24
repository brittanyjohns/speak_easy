# == Schema Information
#
# Table name: boards
#
#  id          :integer          not null, primary key
#  grid_size   :string
#  name        :string
#  theme_color :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_boards_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class Board < ApplicationRecord
  belongs_to :user
  has_many :board_images, dependent: :destroy
  has_many :images, through: :board_images

  def remaining_images
    Image.all - images
  end

  def self.grid_size_options
    ["2x2", "3x3", "4x4", "5x5", "6x6", "7x7", "8x8"]
  end

  def self.theme_color_options
    ["blue", "green", "red", "yellow"]
  end

  def column_count
    grid_size.split("x")[0].to_i
  end

  def row_count
    grid_size.split("x")[1].to_i
  end

  def max_image_count
    column_count * row_count
  end

  def full?
    images.count == max_image_count
  end
end
