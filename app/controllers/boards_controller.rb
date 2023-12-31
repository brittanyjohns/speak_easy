class BoardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_board, only: %i[ show edit update destroy locked ]

  # GET /boards or /boards.json
  def index
    @boards = current_user.boards.includes(board_images: [:image])
    @default_boards = Board.default_boards
    @general_board = Board.general_board
  end

  # GET /boards/1 or /boards/1.json
  def show
    @board_images = @board.images.with_attached_saved_image.order(created_at: :desc)
    if params[:query].present?
      @query = params[:query]
      @remaining_images = @board.remaining_images.where("label ILIKE ?", "%#{params[:query]}%").with_attached_saved_image.order(label: :asc).page(params[:page]).per(20)
    else
      @remaining_images = @board.remaining_images.with_attached_saved_image.order(label: :asc).page(params[:page]).per(20)
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
    @board = current_user.boards.new(static: true)
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

  def associate_image
    set_boards
    @board = @boards.find(params[:id])
    image = Image.find(params[:image_id])

    unless @board.images.include?(image)
      new_board_image = @board.board_images.new(image: image)
      unless new_board_image.save
        Rails.logger.debug "new_board_image.errors: #{new_board_image.errors.full_messages}"
      end
    end

    redirect_back_or_to @board
  end

  def remove_image
    set_boards
    @board = @boards.find(params[:id])
    image = Image.find(params[:image_id])
    @board.images.delete(image)
    # @response_board = @board.response_board
    # response_image = @response_board.response_images.find_by(image_id: params[:image_id])
    # response_image.destroy if response_image
    redirect_back_or_to @board
    # render partial: "board_images/board_image", collection: @board.board_images.includes(image: [saved_image_attachment: :blob]).order(label: :asc).references(:images), as: :board_image
  end

  def build
    set_boards
    @board = @boards.find(params[:id])
    if params[:image_ids].present?
      image_ids = params[:image_ids].split(",").map(&:to_i)
      @image_ids_to_add = image_ids - @board.image_ids
    end
    if params[:query].present?
      @query = params[:query]
      @remaining_images = @board.remaining_images.where("label ILIKE ?", "%#{params[:query]}%").order(label: :asc).with_attached_saved_image.page(params[:page]).per(20)
    else
      @remaining_images = @board.remaining_images.with_attached_saved_image.order(label: :asc).page(params[:page]).per(20)
    end

    if turbo_frame_request?
      render partial: "select_images", locals: { images: @remaining_images }
    else
      render :build
    end
  end

  def add_multiple_images
    set_boards
    @board = @boards.find(params[:id])

    if params[:image_ids].present?
      @image_ids = params[:image_ids]
      puts "\n\n****image_ids: #{@image_ids}\n\n"
      @image_ids.each do |image_id|
        @board.add_image(image_id)
      end
    else
      puts "no image_ids"
    end
    redirect_back_or_to build_board_path(@board)
  end

  def mark_as_favorite
    @board = Board.searchable_boards_for(current_user).find(params[:id])
    @board.favorite = true
    @board.save!
    redirect_back_or_to @board
  end

  def unfavorite
    @board = Board.searchable_boards_for(current_user).find(params[:id])
    @board.favorite = false
    @board.save!
    redirect_back_or_to @board
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

  def set_boards
    if current_user.admin?
      @boards = Board.all.includes(board_images: [:image])
    else
      @boards = Board.searchable_boards_for(current_user).includes(board_images: [:image])
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_board
    @boards = Board.searchable_boards_for(current_user).includes(board_images: [:image])
    begin
      if current_user.admin?
        # @boards = Board.all.includes(board_images: [:image])
        @board = @boards.find(params[:id])
      else
        # @boards = current_user.boards.includes(board_images: [:image])
        @board = @boards.find(params[:id])
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to boards_url, notice: "Board not found"
    end
  end

  # Only allow a list of trusted parameters through.
  def board_params
    params.require(:board).permit(:static, :user_id, :name, :theme_color, :grid_size, :next_board_id, next_board_attributes: [:id, :name, :theme_color, :grid_size], previous_board_attributes: [:id, :name, :theme_color, :grid_size])
  end

  def update_board_params
    params.require(:board).permit(:static, :user_id, :name, :theme_color, :grid_size, :next_board_id, :previous_board_id)
  end
end
