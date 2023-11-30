class SavesController < ApplicationController
  skip_before_action :require_login, only: %i[index new create show download]

  before_action :set_save, only: %i[show download]
  before_action :set_internal_save, only: %i[edit update destroy]

  def index
    @saves = Save.includes(:user).order(download_count: :desc)
  end

  def show
  end

  def new
    @save = Save.new
  end

  def edit
  end

  def create
    @save = Save.new(save_params)
    @save.user = Current.user if Current.user

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
    @save.increament_download_count!
    send_data @save.save_file, filename: @save.title, disposition: "attachment"
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
