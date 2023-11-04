class ResponseBoardsController < ApplicationController
  before_action :set_response_board, only: %i[ show ]

  def index
    @response_boards = ResponseBoard.all
  end

  def show
  end

  private

  def set_response_board
    @response_board = ResponseBoard.find(params[:id])
  end
end
