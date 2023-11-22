class BoardImagesController < ApplicationController
  before_action :authenticate_user!, :set_current_user

  # GET /board_images/1 or /board_images/1.json
  def show
  end

  # GET /board_images/new
  def new
    @board_image = BoardImage.new
  end

  # GET /board_images/1/edit
  def edit
    if @board_image.user != current_user && !current_user.admin?
      redirect_to images_url, notice: "You can only edit your own images."
      # elsif @board_image.saved_image.attached? && !@board_image.cropped_image.attached?
      #   redirect_to crop_image_url(@board_image), notice: "You must crop your image before continuing."
    end
  end

  # POST /board_images or /board_images.json
  def create
    @board_image = BoardImage.new(board_image_params)
    @board_image.user = current_user

    respond_to do |format|
      if @board_image.save
        format.html { redirect_to board_image_url(@board_image) }
        format.json { render :show, status: :created, location: @board_image }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @board_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /board_images/1 or /board_images/1.json
  def update
    respond_to do |format|
      if @board_image.update(board_image_params)
        format.html { redirect_to board_image_url(@board_image), notice: "Image was successfully updated." }
        format.json { render :show, status: :ok, location: @board_image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @board_image.errors, status: :unprocessable_entity }
      end
    end
  end

  def next
    @board_image = BoardImage.find(params[:board_image_id])
    @board = @board_image.board
    @next_board = @board.next_board
    if @next_board
      render json: { status: "success", redirect_url: locked_board_path(@next_board) }
    else
      render json: { status: "success", redirect_url: edit_board_path(@board) }
    end
  end

  def previous
    @board_image = BoardImage.find(params[:board_image_id])
    @board = @board_image.board
    @previous_board = @board.previous_board
    if @previous_board
      render json: { status: "success", redirect_url: board_path(@previous_board) }
    else
      render json: { status: "success", redirect_url: edit_board_path(@board) }
    end
  end

  private

  def set_board_image
    @board_image = BoardImage.find(params[:id])
  end
end
