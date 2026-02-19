module ApplicationHelper
  # Exchange rates relative to USD
  EXCHANGE_RATES = {
    'USD' => 1.0,
    'EUR' => 0.92,
    'GBP' => 0.79,
    'JPY' => 149.50,
    'CHF' => 0.88,
    'CAD' => 1.36,
    'AUD' => 1.53
  }.freeze

  def convert_to_currency(amount_in_usd, target_currency)
    rate = EXCHANGE_RATES[target_currency] || 1.0
    amount_in_usd * rate
  end

  def currency_symbol(currency)
    {
      'USD' => '$',
      'EUR' => '€',
      'GBP' => '£',
      'JPY' => '¥',
      'CHF' => 'CHF',
      'CAD' => 'C$',
      'AUD' => 'A$'
    }[currency] || '$'
  end
end
