#Configure the Elasticsearch client with retry logic
Elasticsearch::Model.client = Elasticsearch::Client.new(
  log: true,
  host: ENV["ES_HOST"] || 'localhost',
  retry_on_failure: 5
)

#After initialization block to check and create the index
Rails.application.config.after_initialize do
  if defined?(Elasticsearch::Model)
    if Message.__elasticsearch__.index_exists?
      Message.__elasticsearch__.refresh_index!
    else
      Message.__elasticsearch__.create_index!(force: true)
      Message.import
    end
  end
end
