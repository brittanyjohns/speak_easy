class DocsController < ApplicationController
  before_action :set_doc, only: %i[ show edit update destroy ]

  # GET /docs or /docs.json
  def index
    @menu = Menu.find(params[:menu_id]) if params[:menu_id]
    @docs = @menu.docs
  end

  # GET /docs/1 or /docs/1.json
  def show
  end

  # GET /docs/new
  def new
    @menu = Menu.find(params[:menu_id]) if params[:menu_id]
    @doc = Doc.new
    @doc.documentable = @menu
  end

  # GET /docs/1/edit
  def edit
  end

  # POST /docs or /docs.json
  def create
    @doc = Doc.new(doc_params)
    @menu = Menu.find(params[:menu_id]) if params[:menu_id]
    @doc.name = @menu.name + " - " + @doc.id.to_s
    @doc.documentable = @menu

    respond_to do |format|
      if @doc.save
        @current_board = @doc.current_board
        format.html { redirect_to menu_url(@menu), notice: "Doc was successfully created." }
        format.json { render :show, status: :created, location: @doc }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @doc.errors, status: :unprocessable_entity }
      end
    end
  end

  def enhance_image_description
    @doc = Doc.find(params[:id])
    @menu = Menu.find(params[:menu_id]) if params[:menu_id]
    # @doc.get_image_description
    @doc.enhance_image_description
    respond_to do |format|
      format.html { redirect_to menu_doc_url(@menu, @doc), notice: "Image description was successfully created." }
      format.json { render :show, status: :created, location: @doc }
    end
  end

  # PATCH/PUT /docs/1 or /docs/1.json
  def update
    respond_to do |format|
      if @doc.update(doc_params)
        format.html { redirect_to menu_doc_url(@menu, @doc), notice: "Doc was successfully updated." }
        format.json { render :show, status: :ok, location: @doc }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /docs/1 or /docs/1.json
  def destroy
    @doc.destroy!

    respond_to do |format|
      format.html { redirect_to menu_docs_url(@menu), notice: "Doc was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_doc
      @menu = Menu.find(params[:menu_id]) if params[:menu_id]
      @doc = Doc.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def doc_params
      params.require(:doc).permit(:name, :documentable_id, :documentable_type, :image, :image_description, :raw_text)
    end
end
