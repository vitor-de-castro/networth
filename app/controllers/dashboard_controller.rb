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

    total_eur = current_user.assets.sum { |a| a.live_value }
    @total_net_worth = total_eur * @rate

    @assets_by_category = current_user.assets
                                  .group_by(&:category)
                                  .transform_values { |assets| assets.sum { |a| a.live_value } * @rate }

    # === QUICK STATS ===
    if @assets.any?
      @biggest_asset = @assets.max_by(&:value)
      @categories_count = @assets.pluck(:category).uniq.count

      if @assets_by_category.any?
        @top_category = @assets_by_category.max_by { |_, v| v }
      end

      crypto_value = current_user.assets.where(category: 'Crypto').sum(:value) * @rate
      @crypto_percentage = total_eur > 0 ? (crypto_value / @total_net_worth * 100).round(1) : 0
    end

    # === NET WORTH HISTORY ===
    snapshots = current_user.net_worth_snapshots.where('date >= ?', 30.days.ago).order(:date)
    @history_data = snapshots.map do |snapshot|
      [snapshot.date, (snapshot.total_value * @rate).round(2)]
    end
  end
end
