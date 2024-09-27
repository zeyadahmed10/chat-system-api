class Chat < ApplicationRecord
  has_many :messages
  validates :chat_number, presence: true, uniqueness: { scope: :application_token }
  validates :application_token, presence: true
  validates :message_count, presence: true

  before_create :set_chat_number

  private

  def set_chat_number
    self.chat_number = (Chat.where(application_token: application_token).maximum(:chat_number) || 0) + 1
  end
end
