class BoardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_board, only: %i[ show edit update destroy locked ]

  # GET /boards or /boards.json
  def index
    @boards = current_user.boards
  end

  # GET /boards/1 or /boards/1.json
  def show
    if params[:query].present?
      @images = @board.remaining_images.where("label ILIKE ?", "%#{params[:query]}%").order(label: :asc)
    else
      @images = @board.remaining_images.order(label: :asc)
    end

    if turbo_frame_request?
      render partial: "board_images", locals: { images: @images }
    else
      render :show
    end
  end

  def locked
    @images = @board.images
  end

  # GET /boards/new
  def new
    @board = current_user.boards.new
  end

  # GET /boards/1/edit
  def edit
  end

  # POST /boards or /boards.json
  def create
    @board = current_user.boards.new(board_params)

    respond_to do |format|
      if @board.save
        format.html { redirect_to board_url(@board), notice: "Board was successfully created." }
        format.json { render :show, status: :created, location: @board }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @board.errors, status: :unprocessable_entity }
      end
    end
  end

  def associate_image
    @board = current_user.boards.find(params[:id])
    image = Image.find(params[:image_id])
    @board.images << image unless @board.images.include?(image)

    redirect_to @board
  end

  def remove_image
    @board = current_user.boards.find(params[:id])
    image = Image.find(params[:image_id])
    @board.images.delete(image)
    redirect_to @board
  end

  # PATCH/PUT /boards/1 or /boards/1.json
  def update
    respond_to do |format|
      if @board.update(board_params)
        format.html { redirect_to board_url(@board), notice: "Board was successfully updated." }
        format.json { render :show, status: :ok, location: @board }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @board.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boards/1 or /boards/1.json
  def destroy
    @board.destroy

    respond_to do |format|
      format.html { redirect_to boards_url, notice: "Board was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_board
    begin
      @board = current_user.boards.includes(:images).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to boards_url, notice: "Board not found"
    end
  end

  # Only allow a list of trusted parameters through.
  def board_params
    params.require(:board).permit(:user_id, :name, :theme_color, :grid_size)
  end
end
