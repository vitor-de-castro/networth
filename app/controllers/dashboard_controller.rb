class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @assets = current_user.assets.order(created_at: :desc)

    # Get user's preferred currency
    @user_currency = current_user.currency || 'USD'
    @currency_symbol = get_currency_symbol(@user_currency)

    # Calculate total in USD first (stored currency)
    total_usd = current_user.assets.sum(:value)

    # Convert to user's preferred currency
    @total_net_worth = convert_currency(total_usd, @user_currency)

    # Asset breakdown by category (also converted)
    @assets_by_category = current_user.assets
                                      .group(:category)
                                      .sum(:value)
                                      .transform_values { |v| convert_currency(v, @user_currency) }
  end

  private

  def convert_currency(amount_in_usd, target_currency)
    rates = {
      'USD' => 1.0,
      'EUR' => 0.92,
      'GBP' => 0.79,
      'JPY' => 149.50,
      'CHF' => 0.88,
      'CAD' => 1.36,
      'AUD' => 1.53
    }
    rate = rates[target_currency] || 1.0
    amount_in_usd * rate
  end

  def get_currency_symbol(currency)
    symbols = {
      'USD' => '$',
      'EUR' => '€',
      'GBP' => '£',
      'JPY' => '¥',
      'CHF' => 'CHF',
      'CAD' => 'C$',
      'AUD' => 'A$'
    }
    symbols[currency] || '$'
  end

  helper_method :convert_currency
end
