class SavesController < ApplicationController
  skip_before_action :require_login, only: %i[index show download]

  before_action :set_save, only: %i[show download]
  before_action :set_internal_save, only: %i[edit update destroy]

  def index
    @saves = Save.includes(:user).all
  end

  def show
  end

  def new
    @save = Current.user.saves.new
  end

  def edit
  end

  def create
    @save = Current.user.saves.new(save_params)

    if @save.save
      redirect_to @save, notice: "Save was successfully created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @save.update(save_params)
      redirect_to @save, notice: "Save was successfully updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @save.destroy!

    redirect_to saves_path, notice: "Save was successfully destroyed"
  end

  def download
    send_data @save.save_file, filename: "LCSaveFile1", disposition: "attachment"
  end

  private

  def set_save
    @save = Save.find(params[:id])
  end

  def set_internal_save
    @save = Current.user.saves.find(params[:id])
  end

  def save_params
    params.require(:save).permit(:title, :description, *Save::CONSTANT_FIELDS.map(&:underscore), *Save::SHIP_ITEM_IDS.keys)
  end
end
