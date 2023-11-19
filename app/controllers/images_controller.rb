class ImagesController < ApplicationController
  before_action :authenticate_user!, :set_current_user
  before_action :set_image, only: %i[ show edit update destroy speak generate crop croppable ]

  # GET /images or /images.json
  def index
    if params[:user_images_only] == "1"
      @images = current_user.images.includes(cropped_image_attachment: :blob, saved_image_attachment: :blob).page params[:page]
    else
      @images = Image.includes(cropped_image_attachment: :blob, saved_image_attachment: :blob).searchable_images_for(current_user).order(created_at: :desc).page params[:page]
    end
    if params[:query].present?
      @images = @images.searchable_images_for(current_user).where("label ILIKE ?", "%#{params[:query]}%").order(created_at: :desc).page params[:page]
    else
      @images = @images.searchable_images_for(current_user).order(created_at: :desc).page params[:page]
    end
    if turbo_frame_request?
      render partial: "images", locals: { images: @images }
    else
      render :index
    end
  end

  def generate
    GenerateImageJob.perform_async(@image.id)
    Rails.logger.info "Generate Image: #{@image.label}"
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
    if @image.user != current_user && !current_user.admin?
      redirect_to images_url, notice: "You can only edit your own images."
      # elsif @image.saved_image.attached? && !@image.cropped_image.attached?
      #   redirect_to crop_image_url(@image), notice: "You must crop your image before continuing."
    end
  end

  # POST /images or /images.json
  def create
    @image = Image.new(image_params)
    @image.user = current_user

    respond_to do |format|
      if @image.save
        format.html { redirect_to image_url(@image) }
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

  def crop
    @image_url = @image.saved_image.attached? ? rails_storage_proxy_path(@image.saved_image) : ""
    @cropped_image_url = @image.cropped_image.attached? ? rails_storage_proxy_path(@image.cropped_image) : ""
  end

  def croppable
    @image.cropped_image.attach(
      io: StringIO.new(Base64.decode64(image_params[:cropped_image])),
      filename: "cropped_image_#{@image.id}.jpg",
      content_type: "image/x-bmp",
    )
    if @image.cropped_image.attached?
      @image.saved_image.purge
    end
    render json: { status: "success", redirect_url: images_url, notice: "Image was successfully cropped & saved." }
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
    params.require(:image).permit(:image_url, :audio_url, :label, :send_request_on_save, :saved_image, :image_prompt, :private, :cropped_image, :category)
  end
end
