module Api
    module V1
      class ChatsController < ApplicationController
        before_action :set_application, only: [:create, :index, :show]
        before_action :set_chat, only: [:show]
  
        def create
          @chat = Chat.new(application_token: @application.application_token)
          unless @chat.valid?
            render json: { errors: @chat.errors.full_messages }, status: :unprocessable_entity
            return
          end
          chat_number = get_next_chat_number
          ChatCreationWorker.perform_async(@application.application_token, chat_number)
          render json: { application_token: @application.application_token,
           number: chat_number, messages_count: 0 }, status: :created
        end
  
        def index
          @chats = Chat.details_by_application_token(@application.application_token)
          render json: @chats.map {|chat| format_chat_response(chat)}
        end
  
        def show
          render json: format_chat_response(@chat), status: :ok
        end
  
        private
  
        def set_application
          @application = Application.find_by(application_token: params["application_application_token".to_sym])
          render_not_found('Application') unless @application
        end
  
        def set_chat
          @chat = Chat.find_by(application_token: @application.application_token, chat_number: params[:chat_number])
          render_not_found('Chat') unless @chat
        end
  
        def render_not_found(resource)
          render json: { error: "#{resource} not found" }, status: :not_found
        end

        def format_chat_response(chat)
            chat.slice(:application_token, :chat_number, :messages_count)
        end

        def get_next_chat_number
          return $redis.incr("chat_number_counter:#{@application.application_token}")
        end

      end
    end
  end
  