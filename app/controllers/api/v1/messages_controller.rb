module Api
    module V1
      class MessagesController < ApplicationController
        before_action :set_chat, only: [:create, :index, :show, :update]
  
        def create
          message_number = @chat.messages.count + 1
          @message = @chat.messages.new(message_params.merge(message_number: message_number))
  
          if @message.save
            render json: { number: @message.message_number }, status: :created
          else
            render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        def index
          @messages = Message.where(application_token: @chat.application_token, chat_number: @chat.chat_number)
          .pluck(:message_number, :body).to_a
          render json: @messages, status: :ok
        end
  
        def show
          message = find_message
          if message
            render json: { number: message.message_number, body: message.body }, status: :ok
          else
            render_not_found('Message')
          end
        end
  
        def update
          message = find_message
          if message.update(message_params)
            render json: { number: message.message_number, body: message.body }, status: :ok
          else
            render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        private
  
        def set_chat
          @chat = Chat.find_by(
          application_token: params["application_application_token".to_sym],
          chat_number: params["chat_chat_number".to_sym])
          render_not_found('Chat') unless @chat
        end
  
        def find_message
          @chat.messages.find_by(message_number: params[:message_number])
        end
  
        def message_params
          params.require(:message).permit(:body)
        end
  
        def render_not_found(resource)
          render json: { error: "#{resource} not found" }, status: :not_found
        end
      end
    end
  end
  