class BoardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_board, only: %i[ show edit update destroy locked ]

  # GET /boards or /boards.json
  def index
    @boards = Board.all
    # @boards = current_user.boards
    @general_board = Board.general_board
  end

  # GET /boards/1 or /boards/1.json
  def show
    @board_images = @board.board_images.includes(image: [saved_image_attachment: :blob]).order(label: :asc).references(:images)
    if params[:query].present?
      @query = params[:query]
      @remaining_images = @board.remaining_images.where("label ILIKE ?", "%#{params[:query]}%").order(label: :asc).page(params[:page]).per(20)
    else
      @remaining_images = @board.remaining_images.order(label: :asc).page(params[:page]).per(20)
    end

    if turbo_frame_request?
      render partial: "select_images", locals: { images: @remaining_images }
    else
      render :show
    end
  end

  def locked
    @response_board = @board.response_board
    @response_images = @response_board.response_images.includes(:image).order(label: :asc).references(:images)
    @board_images = @board.board_images.includes(:image)
    @send_to_ai = true
    render layout: "play_mode"
  end

  # GET /boards/new
  def new
    @board = current_user.boards.new
    @board.next_board ||= @board.build_next_board
  end

  # GET /boards/1/edit
  def edit
    @board.next_board ||= @board.build_next_board
  end

  # POST /boards or /boards.json
  def create
    @board = current_user.boards.new(update_board_params)
    if board_params[:next_board_id].present?
      next_board = Board.find(board_params[:next_board_id])
      @board.next_board = next_board if next_board
    elsif board_params[:next_board_attributes].present? && !board_params[:next_board_attributes][:name].blank?
      name = board_params[:next_board_attributes][:name]
      @board.create_next_board(name) if name.present?
    end
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

  def find_or_create_image
    @board = current_user.boards.find(params[:id])
    @image = Image.find_or_create_by(label: params[:label])
    @board.images << @image unless @board.images.include?(@image)
  end

  def associate_image
    @board = current_user.boards.find(params[:id])
    image = Image.find(params[:image_id])

    before = @board.images.include?(image)
    @board.board_images.create(image: image) unless @board.images.include?(image)
    @response_board = @board.response_board
    @response_board.response_images.create(image: image) unless @response_board.images.include?(image)

    redirect_to @board
  end

  def remove_image
    @board = current_user.boards.find(params[:id])
    board_image = @board.board_images.find(params[:image_id])
    board_image.destroy
    @response_board = @board.response_board
    response_image = @response_board.response_images.find_by(image_id: params[:image_id])
    render partial: "board_images", locals: { images: @board.images }
  end

  # PATCH/PUT /boards/1 or /boards/1.json
  def update
    if board_params[:next_board_id].present?
      next_board = Board.find(board_params[:next_board_id])
      @board.next_board = next_board if next_board
    elsif board_params[:next_board_attributes].present? && !board_params[:next_board_attributes][:name].blank?
      name = board_params[:next_board_attributes][:name]
      @board.create_next_board(name) if name.present?
    end
    respond_to do |format|
      if @board.update(update_board_params)
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
      if current_user.admin?
        @board = Board.find(params[:id])
      else
        @board = Board.all_boards_for_user(current_user).includes(board_images: [:image]).find(params[:id])
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to boards_url, notice: "Board not found"
    end
  end

  # Only allow a list of trusted parameters through.
  def board_params
    params.require(:board).permit(:user_id, :name, :theme_color, :grid_size, :next_board_id, next_board_attributes: [:id, :name, :theme_color, :grid_size], previous_board_attributes: [:id, :name, :theme_color, :grid_size])
  end

  def update_board_params
    params.require(:board).permit(:user_id, :name, :theme_color, :grid_size, :next_board_id, :previous_board_id)
  end
end
