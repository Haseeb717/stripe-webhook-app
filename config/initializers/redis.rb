class RedisClient
  def self.instance
    @instance ||= Redis.new(url: ENV['REDIS_URL'])
  end
end
