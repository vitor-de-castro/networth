require 'json'

class MarketDataCache
  CACHE_FILE = Rails.root.join('tmp', 'market_data_cache.json')

  def self.get(key)
    cache = read_cache
    data = cache[key]
    return nil unless data

    # Return cached data with timestamp
    {
      price: data['price'],
      change: data['change'],
      cached_at: Time.parse(data['cached_at']),
      is_cached: true
    }
  rescue => e
    Rails.logger.error("Cache read error: #{e.message}")
    nil
  end

  def self.set(key, price, change)
    cache = read_cache
    cache[key] = {
      'price' => price,
      'change' => change,
      'cached_at' => Time.current.to_s
    }
    write_cache(cache)
  rescue => e
    Rails.logger.error("Cache write error: #{e.message}")
  end

  private

  def self.read_cache
    return {} unless File.exist?(CACHE_FILE)
    JSON.parse(File.read(CACHE_FILE))
  rescue JSON::ParserError
    {}
  end

  def self.write_cache(data)
    FileUtils.mkdir_p(File.dirname(CACHE_FILE))
    File.write(CACHE_FILE, data.to_json)
  end
end
