class Application < ApplicationRecord
  has_many :chats

  before_validation :generate_unique_token

  validates :application_token, presence: true
  validates :name, presence: true

  private

  def generate_unique_token
    return if self.application_token.present? #preventing to update the application token
    loop do
      self.application_token = "#{SecureRandom.hex(8)}#{Time.now.to_i}"
      break unless Application.exists?(application_token: application_token)
    end
  end
end
