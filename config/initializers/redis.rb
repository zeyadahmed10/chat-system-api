require 'redis'
redis_url = 'redis://'+ENV['REDIS_HOST'] || 'redis://localhost'
$redis = Redis.new(url: redis_url, timeout: 5, reconnect_attempts: 3)

