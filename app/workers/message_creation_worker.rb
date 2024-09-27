class MessageCreationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'messages'

  def perform(action, application_token, chat_number, message_number, body)
    case action
    when 'save'
      perform_save(application_token, chat_number, message_number, body)
    when 'update'
      perform_update(application_token, chat_number, message_number, body)
    else
      Rails.logger.error "Invalid action: #{action}"
    end
  end

  private

  def perform_save(application_token, chat_number, message_number, body)
    message = Message.new(application_token: application_token, chat_number: chat_number, message_number: message_number, body: body)  
    if message.save
      Rails.logger.info "Message created successfully: #{message.message_number}"
    else
      Rails.logger.error "Failed to create message: #{message.errors.full_messages.join(', ')}"
    end
  end

  def perform_update(application_token, chat_number, message_number, body)
    message = Message.find_by(application_token: application_token,
    chat_number: chat_number,
    message_number: message_number)
    if message.update(body: body) 
      Rails.logger.info "Message updated successfully: #{message.message_number}"
    else
      Rails.logger.error "Failed to update message: #{message ? message.errors.full_messages.join(', ') : 'Message not found'}"
    end
  end
end
