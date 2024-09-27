class Chat < ApplicationRecord
  has_many :messages
  validates :chat_number, presence: true, uniqueness: { scope: :application_token }
  validates :application_token, presence: true
  validates :messages_count, presence: true

  
  before_validation :set_chat_number
  #custom method get the value from indexing the application_token
  def self.details_by_application_token(application_token)
    select(:chat_number, :messages_count, :created_at, :updated_at)
      .where(application_token: application_token)
  end
  private

  def set_chat_number
    return if self.chat_number.present? #preventing updating the chat_number
    self.chat_number = $redis.incr("chat_number_counter:#{self.application_token}")
  end
end
