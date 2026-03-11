require 'net/http'
require 'json'

class ExchangeRateService
  FALLBACK_RATE = 1.17  # Manual backup rate

  def self.get_usd_to_eur_rate
    # Try to fetch live rate
    live_rate = fetch_live_rate
    return live_rate if live_rate

    # Fallback to manual rate
    Rails.logger.warn("Using fallback exchange rate: #{FALLBACK_RATE}")
    FALLBACK_RATE
  end

  private

  def self.fetch_live_rate
    uri = URI('https://api.exchangerate-api.com/v4/latest/EUR')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 3
    http.read_timeout = 3

    request = Net::HTTP::Get.new(uri)
    response = http.request(request)

    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    usd_rate = data.dig('rates', 'USD')

    return usd_rate if usd_rate && usd_rate > 0
    nil
  rescue => e
    Rails.logger.error("Exchange rate fetch failed: #{e.message}")
    nil
  end
end
