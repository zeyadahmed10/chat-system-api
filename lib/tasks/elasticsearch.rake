namespace :es do
    desc "create elasticsearch index"
    task :create_index => :environment do
      Message.__elasticsearch__.create_index!
      Message.__elasticsearch__.refresh_index!
    end
  end

# namespace :es do
#   desc "create elasticsearch index"
#   task create_index: :environment do
#     require 'elasticsearch'
#     client = Elasticsearch::Client.new(host: 'elasticsearch', port: 9200)

#     retries = 5
#     begin
#       # Ping Elasticsearch to ensure it's up
#       client.ping
#       # If Elasticsearch is reachable, create and refresh index
#       Message.__elasticsearch__.create_index!
#       Message.__elasticsearch__.refresh_index!
#       puts "Index created and refreshed successfully."
#     rescue Faraday::ConnectionFailed => e
#       if (retries -= 1) >= 0
#         puts "Elasticsearch is not reachable, retrying... (#{5 - retries}/5)"
#         sleep 5
#         retry
#       else
#         puts "Failed to connect to Elasticsearch: #{e.message}"
#         raise
#       end
#     end
#   end
# end
