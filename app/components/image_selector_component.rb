# frozen_string_literal: true

class ImageSelectorComponent < ViewComponent::Base
  include ImagesHelper

  def initialize(board:, images:)
    @board = board
    @images = images
  end
end
