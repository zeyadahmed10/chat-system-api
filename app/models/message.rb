class Message < ApplicationRecord
  
  before_validation :set_message_number

  validates :message_number, presence: true
  validates :body, presence: true
  validates :application_token, presence: true
  validates :chat_number, presence: true

  private

  def set_message_number
    return if self.message_number.present? #preventing updating the chat_number
    self.message_number = $redis.incr("message_number_counter:#{application_token}:#{chat_number}")
  end
end