require 'redis'
redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'
$redis = Redis.new(url: redis_url, timeout: 5, reconnect_attempts: 3)

