require 'net/http'
require 'json'

class MarketDataService
  def self.fetch_all
    {
      stocks: fetch_stocks,
      crypto: fetch_crypto,
      commodities: fetch_commodities
    }
  end

  def self.fetch_stocks
    Rails.logger.info("=== Starting stock fetch ===")

    begin
      # Fetch S&P 500
      sp500 = fetch_yahoo_quote('^GSPC')

      # Small delay to avoid rate limiting
      sleep(0.5)

      # Fetch NASDAQ
      nasdaq = fetch_yahoo_quote('^IXIC')

      {
        sp500: sp500,
        nasdaq: nasdaq
      }
    rescue => e
      Rails.logger.error("Stock fetch error: #{e.message}")
      {
        sp500: { error: true },
        nasdaq: { error: true }
      }
    end
  end

  def self.fetch_yahoo_quote(symbol)
    # Try to fetch live data
    live_data = fetch_yahoo_quote_raw(symbol)

    if live_data && !live_data[:error]
      # Cache successful fetch
      MarketDataCache.set("stock_#{symbol}", live_data[:price], live_data[:change])
      return live_data
    end

    # On error, try cache
    cached = MarketDataCache.get("stock_#{symbol}")
    return cached if cached

    # No cache available
    { error: true }
  end

  def self.fetch_yahoo_quote_raw(symbol)
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
      return { error: true }
    end

    data = JSON.parse(response.body)

    # Extract data from Yahoo's response
    result = data.dig('chart', 'result', 0)
    return { error: true } unless result

    meta = result['meta']
    return { error: true } unless meta

    current_price = meta['regularMarketPrice']
    previous_close = meta['previousClose']

    return { error: true } unless current_price && previous_close

    # Calculate percentage change
    change_percent = ((current_price - previous_close) / previous_close * 100)

    {
      price: current_price,
      change: change_percent
    }
  rescue => e
    Rails.logger.error("Yahoo quote error for #{symbol}: #{e.message}")
    { error: true }
  end

  def self.fetch_crypto
    begin
      uri = URI('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=eur&include_24hr_change=true')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 5

      request = Net::HTTP::Get.new(uri)
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)

        {
          bitcoin: fetch_and_cache_crypto('bitcoin', data['bitcoin']),
          ethereum: fetch_and_cache_crypto('ethereum', data['ethereum']),
          solana: fetch_and_cache_crypto('solana', data['solana'])
        }
      else
        # All failed, try cache
        {
          bitcoin: MarketDataCache.get('crypto_bitcoin') || { error: true },
          ethereum: MarketDataCache.get('crypto_ethereum') || { error: true },
          solana: MarketDataCache.get('crypto_solana') || { error: true }
        }
      end
    rescue => e
      Rails.logger.error("Crypto fetch error: #{e.message}")
      {
        bitcoin: MarketDataCache.get('crypto_bitcoin') || { error: true },
        ethereum: MarketDataCache.get('crypto_ethereum') || { error: true },
        solana: MarketDataCache.get('crypto_solana') || { error: true }
      }
    end
  end

  def self.fetch_commodities
    begin
      uri = URI('https://api.coingecko.com/api/v3/simple/price?ids=pax-gold,silver-tokenized-stock-defichain&vs_currencies=eur&include_24hr_change=true')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 5

      request = Net::HTTP::Get.new(uri)
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)

        {
          gold: fetch_and_cache_crypto('gold', data['pax-gold']),
          silver: fetch_and_cache_crypto('silver', data['silver-tokenized-stock-defichain'])
        }
      else
        {
          gold: MarketDataCache.get('crypto_gold') || { error: true },
          silver: MarketDataCache.get('crypto_silver') || { error: true }
        }
      end
    rescue => e
      Rails.logger.error("Commodities fetch error: #{e.message}")
      {
        gold: MarketDataCache.get('crypto_gold') || { error: true },
        silver: MarketDataCache.get('crypto_silver') || { error: true }
      }
    end
  end

  def self.fetch_single_crypto(coin_id)
    # Try live fetch
    live_data = fetch_single_crypto_raw(coin_id)

    if live_data && !live_data[:error]
      MarketDataCache.set("crypto_#{coin_id}", live_data[:price], live_data[:change])
      return live_data
    end

    # Fallback to cache
    cached = MarketDataCache.get("crypto_#{coin_id}")
    return cached if cached

    { error: true }
  end

  def self.fetch_single_crypto_raw(coin_id)
    uri = URI("https://api.coingecko.com/api/v3/simple/price?ids=#{coin_id}&vs_currencies=eur&include_24hr_change=true")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 5

    request = Net::HTTP::Get.new(uri)
    response = http.request(request)

    return { error: true } unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    coin_data = data[coin_id]

    return { error: true } unless coin_data && coin_data['eur']

    {
      price: coin_data['eur'],
      change: coin_data['eur_24h_change'] || 0
    }
  rescue => e
    Rails.logger.error("Single crypto fetch error for #{coin_id}: #{e.message}")
    { error: true }
  end

  private

  def self.fetch_and_cache_crypto(key, crypto_data)
    parsed = parse_crypto(crypto_data)

    if parsed && !parsed[:error]
      MarketDataCache.set("crypto_#{key}", parsed[:price], parsed[:change])
      return parsed
    end

    # Try cache on error
    MarketDataCache.get("crypto_#{key}") || { error: true }
  end

  def self.parse_crypto(crypto_data)
    return { error: true } unless crypto_data && crypto_data['eur']

    {
      price: crypto_data['eur'],
      change: crypto_data['eur_24h_change'] || 0
    }
  end
end
