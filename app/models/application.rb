class Application < ApplicationRecord
    before_create :generate_unique_token
  
    validates :token, presence: true, uniqueness: true
    validates :name, presence: true
    private
  
    def generate_unique_token
      loop do
        self.application_token = "#{SecureRandom.hex(8)}#{Time.now.to_i}"
        break unless Application.exists?(application_token: application_token)
      end
    end
  end
  
  