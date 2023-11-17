# == Schema Information
#
# Table name: response_images
#
#  id                :bigint           not null, primary key
#  click_count       :integer          default(0)
#  final_response    :boolean          default(FALSE)
#  label             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  image_id          :bigint           not null
#  response_board_id :bigint           not null
#
# Indexes
#
#  index_response_images_on_image_id           (image_id)
#  index_response_images_on_response_board_id  (response_board_id)
#
# Foreign Keys
#
#  fk_rails_...  (image_id => images.id)
#  fk_rails_...  (response_board_id => response_boards.id)
#
class ResponseImage < ApplicationRecord
  belongs_to :response_board
  belongs_to :image

  before_save :set_label
  broadcasts_to ->(response_image) { :response_image_list }, inserts_by: :prepend, target: "response_image_list"

  validates :label, presence: true
  validates :image_id, presence: true
  validates :response_board_id, presence: true
  validates_uniqueness_of :image_id, scope: :response_board_id

  def set_label
    self.label = image.label
  end

  def display_image
    image.display_image
  end

  def private
    image.private
  end

  def label
    image.label
  end
end
