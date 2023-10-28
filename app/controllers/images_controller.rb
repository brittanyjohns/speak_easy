class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_image, only: %i[ show edit update destroy speak generate ]

  # GET /images or /images.json
  def index
    puts "\n\nPARAMS: #{params}\n\n"
    if params[:user_images_only] == "1"
      puts "user images only"
      @images = current_user.images
    else
      @images = Image.searchable_images_for(current_user).order(label: :asc)
    end
    if params[:query].present?
      puts "query present"
      @images = @images.searchable_images_for(current_user).where("label ILIKE ?", "%#{params[:query]}%").order(label: :asc)
    else
      puts "no query"
      @images = @images.searchable_images_for(current_user).order(label: :asc)
    end
    if turbo_frame_request?
      puts "Turbo frame request"
      render partial: "images", locals: { images: @images }
    else
      render :index
    end
  end

  def generate
    GenerateImageJob.perform_async(@image.id)
    redirect_to images_url, notice: "Your image is generating."
  end

  # GET /images/1 or /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
    unless @image.user == current_user
      redirect_to images_url, notice: "You can only edit your own images."
    end
  end

  # POST /images or /images.json
  def create
    @image = Image.new(image_params)
    @image.user = current_user
    respond_to do |format|
      if @image.save
        format.html { redirect_to image_url(@image), notice: "Image was successfully created." }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1 or /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to image_url(@image), notice: "Image was successfully updated." }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1 or /images/1.json
  def destroy
    @image.destroy

    respond_to do |format|
      format.html { redirect_to images_url, notice: "Image was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find(params[:id])
    puts "set_image: #{@image}"
  end

  # Only allow a list of trusted parameters through.
  def image_params
    params.require(:image).permit(:image_url, :audio_url, :label, :send_request_on_save, :saved_image, :image_prompt, :private)
  end
end
