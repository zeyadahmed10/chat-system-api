class Message < ApplicationRecord

  validates :body, presence: true
  validates :application_token, presence: true
  validates :chat_number, presence: true

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks



  index_name 'messages_es_index'

  # Elasticsearch index settings with keyword fields for filtering
  es_index_settings = {
    analysis: {
      filter: {
        trigrams_filter: {
          type: 'ngram',
          min_gram: 3,
          max_gram: 3
        }
      },
      analyzer: {
        trigrams: {
          type: 'custom',
          tokenizer: 'standard',
          filter: [
            'lowercase',
            'trigrams_filter'
          ]
        }
      }
    }
  }

  settings es_index_settings do
    mapping dynamic: 'false' do
      indexes :application_token, type: 'keyword'
      indexes :chat_number, type: 'integer'
      indexes :body, type: 'text', analyzer: 'trigrams'
    end
  end

  def self.search_elastic(application_token, chat_number, query)
    search_definition = {
      query: {
        bool: {
          must: [
            { term: { application_token: application_token } },
            { term: { chat_number: chat_number } },
            {
              match: {
                body: {
                  query: query,
                  analyzer: 'trigrams'
                }
              }
            }
          ]
        }
      }
    }

    response = __elasticsearch__.search(search_definition).to_a
    results = []
    #casting manually for avoiding implicit conversion errors
    response.each do |item|
      body = item['_source']['body']
      message_number = item['_source']['message_number']
      results.push(Message.new(application_token: application_token, chat_number: chat_number, body: body, message_number: message_number))
    end
    return results
  end
  
end