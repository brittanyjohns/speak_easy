# frozen_string_literal: true

class ImageSelectorComponent < ViewComponent::Base
  include ImagesHelper

  def initialize(board:)
    @board = board
    @images = @board.remaining_images.order(label: :asc)
  end

  def render?
    !@board.full?
  end
end
