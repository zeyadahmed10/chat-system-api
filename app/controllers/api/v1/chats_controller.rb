module Api
    module V1
      class ChatsController < ApplicationController
        before_action :set_application, only: [:create, :index, :show]
        before_action :set_chat, only: [:show]
  
        def create
          return render_not_found('Application') unless @application
  
          @chat = Chat.new(application_token: @application.application_token)
  
          if @chat.save
            render json: { number: @chat.chat_number, messages_count: @chat.messages_count }, status: :created
          else
            render json: { errors: @chat.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        def index
          return render_not_found('Application') unless @application
  
          @chats = Chat.details_by_application_token(@application.application_token)
          render json: @chats.map {|chat| format_chat_response(chat)}

        end
  
        def show
          return render_not_found('Chat') unless @chat
  
          render json: { number: @chat.chat_number, messages_count: @chat.messages_count }, status: :ok
        end
  
        private
  
        def set_application
          @application = Application.find_by(application_token: params["application_application_token".to_sym])
          render_not_found('Application') unless @application
        end
  
        def set_chat
          @chat = Chat.find_by(chat_number: params[:chat_number], application_token: @application.application_token)
          render_not_found('Chat') unless @chat
        end
  
        def render_not_found(resource)
          render json: { error: "#{resource} not found" }, status: :not_found
        end

        def format_chat_response(chat)
            chat.slice(:chat_number, :messages_count, :created_at, :updated_at)
        end
      end
    end
  end
  