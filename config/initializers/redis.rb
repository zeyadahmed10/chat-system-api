require 'redis'
redis_url = ENV['REDIS_HOST'] || 'redis://localhost'
$redis = Redis.new(url: redis_url, timeout: 5, reconnect_attempts: 3)

