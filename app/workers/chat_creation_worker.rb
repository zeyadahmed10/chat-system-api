class ChatCreationWorker
    include Sidekiq::Worker
    
    sidekiq_options queue: 'chats'

    def perform(application_token, chat_number)
      chat = Chat.new(application_token: application_token, chat_number: chat_number)  
      if chat.save
        Rails.logger.info "Chat created successfully: #{chat.chat_number}"
      else
        Rails.logger.error "Failed to create chat: #{chat.errors.full_messages.join(', ')}"
      end
    end
  end
  