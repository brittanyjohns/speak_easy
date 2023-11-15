class BoardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_board, only: %i[ show edit update destroy locked ]

  # GET /boards or /boards.json
  def index
    @boards = current_user.boards
  end

  # GET /boards/1 or /boards/1.json
  def show
    @board_images = @board.board_images.includes(:image).order(label: :asc).references(:images)
    if params[:query].present?
      @query = params[:query]
      @remaining_images = @board.remaining_images.where("label ILIKE ?", "%#{params[:query]}%").order(label: :asc).page(params[:page]).per(20)
    else
      @remaining_images = @board.remaining_images.order(label: :asc).page(params[:page]).per(20)
    end

    # respond_to do |format|
    #   format.html
    #   format.turbo_stream { render turbo_stream: turbo_stream.replace("select_images", partial: "select_images", locals: { images: @remaining_images }) }
    # end

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
    # @images = @board.response_board.response_images.includes(:image).order(label: :asc).references(:images)
    @send_to_ai = true
    render layout: "play_mode"
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
    # @board.images << image unless @board.images.include?(image)

    redirect_to @board, notice: "#{before} -@board.images.include?(image): #{@board.images.include?(image)}"
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
      @board = current_user.boards.includes(board_images: [:image]).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to boards_url, notice: "Board not found"
    end
  end

  # Only allow a list of trusted parameters through.
  def board_params
    params.require(:board).permit(:user_id, :name, :theme_color, :grid_size)
  end
end
