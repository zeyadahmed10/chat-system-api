require 'sidekiq'
require 'sidekiq-scheduler'

redis_url = ENV['REDIS_HOST'] || 'redis://localhost'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, network_timeout: 5, reconnect_attempts: 3 }
  schedule_file = "config/sidekiq.yml"

  if File.exist?(schedule_file) && Sidekiq.server?
    Sidekiq::Scheduler.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, network_timeout: 5, reconnect_attempts: 3 }
end