class SavesController < ApplicationController
  before_action :set_save, only: %i[ show edit update destroy download ]

  # GET /saves or /saves.json
  def index
    @saves = Save.all
  end

  # GET /saves/1 or /saves/1.json
  def show
  end

  # GET /saves/new
  def new
    @save = Save.new
  end

  # GET /saves/1/edit
  def edit
  end

  # POST /saves or /saves.json
  def create
    @save = Save.new(save_params)

    respond_to do |format|
      if @save.save
        format.html { redirect_to save_url(@save), notice: "Save was successfully created." }
        format.json { render :show, status: :created, location: @save }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @save.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /saves/1 or /saves/1.json
  def update
    respond_to do |format|
      if @save.update(save_params)
        format.html { redirect_to save_url(@save), notice: "Save was successfully updated." }
        format.json { render :show, status: :ok, location: @save }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @save.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /saves/1 or /saves/1.json
  def destroy
    @save.destroy!

    respond_to do |format|
      format.html { redirect_to saves_url, notice: "Save was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def download
    send_data @save.save_file, filename: 'LCSaveFile1', disposition: "attachment"
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_save
    @save = Save.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def save_params
    params.require(:save).permit(:title, :description, *Save::CONSTANT_FIELDS.map(&:underscore), *Save::SHIP_ITEM_IDS.keys)
  end
end
