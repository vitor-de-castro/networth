require 'net/http'
require 'json'

class MarketDataService
  def self.fetch_all
    {
      stocks: fetch_stocks,
      crypto: fetch_crypto
    }
  end

  def self.fetch_stocks
    Rails.logger.info("=== Starting stock fetch ===")

    begin
      # Fetch S&P 500
      Rails.logger.info("Fetching S&P 500...")
      sp500 = fetch_yahoo_quote('^GSPC')
      Rails.logger.info("S&P 500 result: #{sp500.inspect}")

      # Small delay to avoid rate limiting
      sleep(0.5)

      # Fetch NASDAQ
      Rails.logger.info("Fetching NASDAQ...")
      nasdaq = fetch_yahoo_quote('^IXIC')
      Rails.logger.info("NASDAQ result: #{nasdaq.inspect}")

      result = {
        sp500: sp500,
        nasdaq: nasdaq
      }

      Rails.logger.info("Final stocks result: #{result.inspect}")
      result
    rescue => e
      Rails.logger.error("Stock fetch error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      { sp500: nil, nasdaq: nil }
    end
  end

  def self.fetch_yahoo_quote(symbol)
    encoded_symbol = URI.encode_www_form_component(symbol)
    uri = URI("https://query1.finance.yahoo.com/v8/finance/chart/#{encoded_symbol}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri)
    request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    request['Accept'] = 'application/json'
    request['Accept-Language'] = 'en-US,en;q=0.9'

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("Yahoo Finance returned #{response.code} for #{symbol}")
      return nil
    end

    data = JSON.parse(response.body)

    # Extract data from Yahoo's response
    result = data.dig('chart', 'result', 0)
    return nil unless result

    meta = result['meta']
    return nil unless meta

    current_price = meta['regularMarketPrice']
    previous_close = meta['previousClose']

    return nil unless current_price && previous_close

    # Calculate percentage change
    change_percent = ((current_price - previous_close) / previous_close * 100)

    {
      price: current_price,
      change: change_percent
    }
  rescue => e
    Rails.logger.error("Yahoo quote error for #{symbol}: #{e.message}")
    nil
  end

  def self.fetch_crypto
    begin
      uri = URI('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=eur&include_24hr_change=true')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 5

      request = Net::HTTP::Get.new(uri)
      response = http.request(request)

      return { bitcoin: nil, ethereum: nil } unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)

      {
        bitcoin: parse_crypto(data['bitcoin']),
        ethereum: parse_crypto(data['ethereum'])
      }
    rescue => e
      Rails.logger.error("Crypto fetch error: #{e.message}")
      { bitcoin: nil, ethereum: nil }
    end
  end

  private

  def self.parse_crypto(crypto_data)
    return nil unless crypto_data && crypto_data['eur']

    {
      price: crypto_data['eur'],
      change: crypto_data['eur_24h_change'] || 0
    }
  end
end
