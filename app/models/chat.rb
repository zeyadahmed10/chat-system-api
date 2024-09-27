class Chat < ApplicationRecord
  has_many :messages
  validates :messages_count, presence: true

  
  #custom method get the value from indexing the application_token
  def self.details_by_application_token(application_token)
    select(:application_token, :chat_number, :messages_count)
      .where(application_token: application_token)
  end
end
