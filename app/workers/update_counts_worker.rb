class UpdateCountsWorker
    include Sidekiq::Worker
  
    sidekiq_options queue: 'default'
  
    def perform
      update_chats_count
      update_messages_count
    end
  
    private
  
    def update_chats_count
      Application.find_each do |application|
        chats_count = Chat.where(application_token: application.application_token).count
        application.update(chats_count: chats_count)
      end
    end
  
    def update_messages_count
      Chat.find_each do |chat|
        messages_count = Message.where(application_token: chat.application_token, chat_number: chat.chat_number).count
        chat.update(messages_count: messages_count)
      end
    end
  end
  