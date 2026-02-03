class AssetsController < ApplicationController
  #before_action :authenticate_user!
  before_action :set_asset, only: [:show, :edit, :update, :destroy]

  def index
    @assets = current_user.assets.order(created_at: :desc)
  end

  def new
    @asset = Asset.new
  end

  def create
    @asset = current_user.assets.build(asset_params)

    if @asset.save
      redirect_to root_path, notice: 'Asset added successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @asset.update(asset_params)
      redirect_to root_path, notice: 'Asset updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @asset.destroy
    redirect_to root_path, notice: 'Asset deleted successfully!'
  end

  private

  def set_asset
    @asset = current_user.assets.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(:category, :name, :value, :notes)
  end
end
