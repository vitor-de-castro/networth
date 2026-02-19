class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @assets = current_user.assets.order(created_at: :desc)

    # Get user's preferred currency
    @user_currency = current_user.currency || 'USD'

    # Exchange rates
    rates = {
      'USD' => 1.0,
      'EUR' => 0.92,
      'GBP' => 0.79,
      'JPY' => 149.50,
      'CHF' => 0.88,
      'CAD' => 1.36,
      'AUD' => 1.53
    }
    @rate = rates[@user_currency] || 1.0

    # Currency symbols
    symbols = {
      'USD' => '$',
      'EUR' => '€',
      'GBP' => '£',
      'JPY' => '¥',
      'CHF' => 'CHF',
      'CAD' => 'C$',
      'AUD' => 'A$'
    }
    @currency_symbol = symbols[@user_currency] || '$'

    # Calculate total (convert from USD to selected currency)
    total_usd = current_user.assets.sum(:value)
    @total_net_worth = total_usd * @rate

    # Asset breakdown by category (converted)
    @assets_by_category = current_user.assets
                                      .group(:category)
                                      .sum(:value)
                                      .transform_values { |v| v * @rate }
  end
end
