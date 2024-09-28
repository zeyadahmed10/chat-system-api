Rails.application.config.after_initialize do
  if defined?(Elasticsearch::Model)
    unless Message.__elasticsearch__.index_exists?
      Message.__elasticsearch__.create_index!(force: true)
      Message.import
    end
  end
end