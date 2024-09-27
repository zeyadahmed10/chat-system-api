class Message < ApplicationRecord
  
  before_create :set_message_number

  validates :message_number, presence: true
  validates :body, presence: true
  validates :application_token, presence: true
  validates :chat_number, presence: true

  private

  def set_message_number
    self.message_number = (Message.where(application_token: application_token, chat_number: chat_number).maximum(:message_number) || 0) + 1
  end
end