class Message < ApplicationRecord
  
  validates :body, presence: true
  validates :application_token, presence: true
  validates :chat_number, presence: true
end