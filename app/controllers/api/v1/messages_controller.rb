module Api
  module V1
    class MessagesController < ApplicationController
      before_action :set_chat, only: [:create, :index, :show, :update]
      before_action :find_message, only: [:show, :update]

      def create
        @message = Message.new(application_token: @chat.application_token,
                               chat_number: @chat.chat_number,
                               body: message_params[:body])
        unless @message.valid?
          render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
          return 
        end
        message_number = get_next_message_number
        MessageCreationWorker.perform_async('save', @chat.application_token, @chat.chat_number, message_number, message_params[:body])
        @message.message_number = message_number
        render json: format_message_response(@message), status: :created
      end

      def index
        @messages = Message.where(application_token: @chat.application_token, chat_number: @chat.chat_number)
        render json: @messages.map { |message| format_message_response(message) }, status: :ok
      end

      def show
        render json: format_message_response(@message), status: :ok
      end

      def update
        @message.body = message_params[:body]
        unless @message.valid?
          render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
          return
        end
        MessageCreationWorker.perform_async('update' ,@message.application_token, @message.chat_number, @message.message_number, message_params[:body])
        render json: format_message_response(@message), status: :ok
      end

      private

      def set_chat
        @chat = Chat.find_by(
          application_token: params[:application_application_token],
          chat_number: params[:chat_chat_number]
        )
        render_not_found('Chat') unless @chat
      end

      def find_message
        @message = Message.find_by(application_token: @chat.application_token,
                                    chat_number: @chat.chat_number,
                                    message_number: params[:message_number])
        render_not_found('Message') unless @message
      end

      def message_params
        params.require(:message).permit(:body)
      end

      def render_not_found(resource)
        render json: { error: "#{resource} not found" }, status: :not_found
      end

      def format_message_response(message)
        {
          application_token: message.application_token,
          chat_number: message.chat_number,
          message_number: message.message_number,
          body: message.body
        }
      end

      def get_next_message_number
        return $redis.incr("message_number_counter:#{@message.application_token}:#{@message.chat_number}")
      end 
    end
  end
end
