class Asset < ApplicationRecord
  belongs_to :user

  CATEGORIES = ['Bank Account', 'Stocks', 'Crypto', 'Property', 'Vehicle', 'Collectible', 'Other']

  CRYPTO_SYMBOLS = ['BTC', 'ETH', 'SOL', 'BNB', 'ADA', 'DOT', 'AVAX', 'MATIC', 'LINK', 'UNI']
  STOCK_SYMBOLS = ['AAPL', 'TSLA', 'MSFT', 'GOOGL', 'AMZN', 'NVDA', 'META', 'AMD', 'COIN', '005930.KS']

  FALLBACK_EUR_TO_USD_RATE = 1.17

  validates :name, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { greater_than: 0 }, allow_nil: true
  validates :symbol, presence: true, if: :track_live?

  before_validation :set_live_value, if: :track_live?
  after_commit :create_net_worth_snapshot

  # Set value based on live price before validation
  def set_live_value
    return unless symbol.present? && quantity.present?

    current_price = fetch_current_price
    if current_price
      self.value = (quantity * current_price).round(2)
    elsif self.value.blank? || self.value.zero?
      # Fallback: if we can't fetch price, require user to set value manually
      self.value = 1 if self.value.blank?
    end
  end

  # Calculate live value if tracking, otherwise use manual value
  def live_value
    return value unless track_live? && symbol.present? && quantity.present?

    current_price = fetch_current_price
    return value unless current_price

    (quantity * current_price).round(2)
  end

  def fetch_current_price
    return nil unless symbol.present?

    case category
    when 'Crypto'
      fetch_crypto_price
    when 'Stocks'
      fetch_stock_price
    else
      nil
    end
  end

  private

  def fetch_crypto_price
    coin_id = crypto_symbol_to_id(symbol)
    return nil unless coin_id

    data = MarketDataService.fetch_single_crypto(coin_id)
    data && !data[:error] ? data[:price] : nil
  end

  def fetch_stock_price
    data = MarketDataService.fetch_yahoo_quote(symbol)
    return nil unless data && !data[:error]

    # Get live exchange rate (with fallback)
    eur_to_usd_rate = ExchangeRateService.get_usd_to_eur_rate

    # Convert USD to EUR
    usd_price = data[:price]
    eur_price = usd_price / eur_to_usd_rate

    eur_price
  end

  def crypto_symbol_to_id(sym)
    mapping = {
      'BTC' => 'bitcoin',
      'ETH' => 'ethereum',
      'SOL' => 'solana',
      'BNB' => 'binancecoin',
      'ADA' => 'cardano',
      'DOT' => 'polkadot',
      'AVAX' => 'avalanche-2',
      'MATIC' => 'matic-network',
      'LINK' => 'chainlink',
      'UNI' => 'uniswap'
    }
    mapping[sym.upcase]
  end

  def create_net_worth_snapshot
    return unless user.present?

    snapshot = user.net_worth_snapshots.find_or_initialize_by(date: Date.today)
    snapshot.total_value = user.assets.sum { |a| a.live_value || a.value }
    snapshot.save
  end
end
