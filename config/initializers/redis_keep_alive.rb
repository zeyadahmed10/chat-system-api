Thread.new do
    loop do
      begin
        $redis.ping
      rescue => e
        Rails.logger.error "Redis keep-alive failed: #{e.message}"
      end
      sleep 300 #5 minutes
    end
  end