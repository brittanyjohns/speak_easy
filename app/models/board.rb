# == Schema Information
#
# Table name: boards
#
#  id                :bigint           not null, primary key
#  grid_size         :string
#  name              :string
#  show_labels       :boolean
#  theme_color       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  next_board_id     :integer
#  parent_id         :integer
#  previous_board_id :integer
#  user_id           :bigint           not null
#
# Indexes
#
#  index_boards_on_next_board_id      (next_board_id)
#  index_boards_on_parent_id          (parent_id)
#  index_boards_on_previous_board_id  (previous_board_id)
#  index_boards_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Board < ApplicationRecord
  belongs_to :user, optional: true
  has_many :board_images, dependent: :destroy
  belongs_to :parent_board, class_name: "Board", optional: true, foreign_key: "parent_id"
  belongs_to :next_board, class_name: "Board", foreign_key: "next_board_id", optional: true
  belongs_to :previous_board, class_name: "Board", foreign_key: "previous_board_id", optional: true

  accepts_nested_attributes_for :next_board, :previous_board

  # validates :name, presence: true

  before_save :set_defaults

  def set_defaults
    self.user ||= User.super_admin
    self.theme_color ||= "blue"
    self.grid_size ||= "4x4"
    self.parent_board ||= self
  end

  def remaining_images
    Image.with_attached_cropped_image.includes(cropped_image_attachment: :blob).searchable_images_for(self.user).excluding(images)
  end

  def self.general_board
    self.where(name: "General", user_id: 1).first
  end

  def create_next_board(name)
    next_board = self.next_board || self.build_next_board
    next_board.name = name
    next_board.previous_board = self
    next_board.user = self.user
    next_board.parent_board = self.parent_board || self
    next_board.save
    Rails.logger.info "NEXT BOARD: #{next_board.inspect}"
    self.next_board_id = next_board.id
    self.save
    next_board
  end

  def images
    board_images.includes(:image).map(&:image)
  end

  def response_board
    ResponseBoard.find_or_create_by(name: name)
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

  def image_ids
    board_images.map(&:image_id)
  end

  def words
    board_images.map(&:id_and_label).join("<br/>").html_safe
  end

  def self.searchable_boards_for(user)
    if user.admin?
      Board.all
    elsif user
      Board.where(user: user).or(Board.where(user_id: User::SUPER_ADMIN_ID))
    else
      Board.where(user_id: User::SUPER_ADMIN_ID)
    end
  end

  def self.searchable_boards_for_select(user)
    searchable_boards_for(user).order(name: :asc).map { |b| [b.name, b.id] }
  end

  def self.searchable_boards_for_select_with_general(user)
    searchable_boards_for_select(user).unshift(["General", 0])
  end

  def self.default_boards
    self.where(user_id: User::SUPER_ADMIN_ID).order(name: :asc)
  end
end
