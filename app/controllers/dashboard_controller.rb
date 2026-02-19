class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @assets = current_user.assets.order(created_at: :desc)

    # Get user's preferred currency
    @user_currency = current_user.currency || 'USD'
    @currency_symbol = currency_symbol(@user_currency)

    # Calculate total in USD first (stored currency)
    total_usd = current_user.assets.sum(:value)

    # Convert to user's preferred currency
    @total_net_worth = convert_to_currency(total_usd, @user_currency)

    # Asset breakdown by category (also converted)
    @assets_by_category = current_user.assets
                                      .group(:category)
                                      .sum(:value)
                                      .transform_values { |v| convert_to_currency(v, @user_currency) }
  end
end
