class AssetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_asset, only: [:edit, :update, :destroy]

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

  # GET /bulk-add-stocks
def bulk_new
  # Just render the form
end

# POST /bulk-add-stocks
def bulk_create
  stocks_text = params[:stocks_text]
  track_live = params[:track_live] == '1'

  if stocks_text.blank?
    flash[:alert] = "Please enter at least one stock"
    redirect_to bulk_new_assets_path and return
  end

  # Parse the input
  lines = stocks_text.strip.split("\n")
  created_count = 0
  errors = []

  lines.each do |line|
    # Skip empty lines
    next if line.strip.blank?

    # Parse: "AAPL, 10" or "AAPL,10" or "AAPL 10"
    parts = line.split(/[,\s]+/).map(&:strip)

    if parts.length < 2
      errors << "Invalid format: #{line} (use: SYMBOL, QUANTITY)"
      next
    end

    symbol = parts[0].upcase
    quantity = parts[1].to_f

    if quantity <= 0
      errors << "Invalid quantity for #{symbol}: #{parts[1]}"
      next
    end

    # Create the asset
    asset = current_user.assets.new(
      name: symbol,
      category: 'Stocks',
      symbol: symbol,
      quantity: quantity,
      track_live: track_live,
      value: 1  # Will be updated by before_validation callback
    )

    if asset.save
      created_count += 1
    else
      errors << "Failed to create #{symbol}: #{asset.errors.full_messages.join(', ')}"
    end
  end

  # Show results
  if created_count > 0
    flash[:notice] = "✅ Successfully created #{created_count} stock(s)!"
  end

  if errors.any?
    flash[:alert] = "⚠️ Errors:\n" + errors.join("\n")
  end

  redirect_to root_path
end



  private

  def set_asset
    @asset = current_user.assets.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(:name, :category, :value, :quantity, :symbol, :track_live)
  end
end
