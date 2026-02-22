class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @market_data = MarketDataService.fetch_all

    @assets = current_user.assets.order(created_at: :desc)

    @user_currency = current_user.currency || 'EUR'

    # Exchange rates (EUR as base = 1.0)
    rates = {
      'EUR' => 1.0,
      'USD' => 1.09,
      'GBP' => 0.86,
      'JPY' => 162.50,
      'CHF' => 0.96,
      'CAD' => 1.48,
      'AUD' => 1.67
    }
    @rate = rates[@user_currency] || 1.0

    symbols = {
      'USD' => '$',
      'EUR' => '€',
      'GBP' => '£',
      'JPY' => '¥',
      'CHF' => 'CHF',
      'CAD' => 'C$',
      'AUD' => 'A$'
    }
    @currency_symbol = symbols[@user_currency] || '€'

    total_eur = current_user.assets.sum(:value)
    @total_net_worth = total_eur * @rate

    @assets_by_category = current_user.assets
                                      .group(:category)
                                      .sum(:value)
                                      .transform_values { |v| v * @rate }
  end
end
