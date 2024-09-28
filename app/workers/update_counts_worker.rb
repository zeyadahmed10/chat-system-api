class UpdateCountsWorker
    include Sidekiq::Worker
  
    sidekiq_options queue: 'default'
  
    def perform
      ActiveRecord::Base.transaction do
        update_chats_count
        update_messages_count
      end
    end
  
    private
  
    def update_chats_count
      Application.find_each do |application|
        chats_count = Chat.where(application_token: application.application_token).count
        unless application.update(chats_count: chats_count)
          raise ActiveRecord::Rollback 
        end
      end
    end
  

    def update_messages_count
      Chat.find_each do |chat|
        messages_count = Message.where(application_token: chat.application_token, chat_number: chat.chat_number).count
        unless chat.update(messages_count: messages_count)
          raise ActiveRecord::Rollback
        end
      end
    end
  end
  