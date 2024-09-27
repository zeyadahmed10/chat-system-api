module Api
  module V1
    class MessagesController < ApplicationController
      before_action :set_chat, only: [:create, :index, :show, :update]
      before_action :find_message, only: [:show, :update]

      def create
        @message = Message.new(application_token: @chat.application_token,
                               chat_number: @chat.chat_number,
                               body: message_params[:body])
        if @message.save
          render json: format_message_response(@message), status: :created
        else
          render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def index
        @messages = Message.where(application_token: @chat.application_token, chat_number: @chat.chat_number)
        render json: @messages.map { |message| format_message_response(message) }, status: :ok
      end

      def show
        render json: format_message_response(@message), status: :ok
      end

      def update
        if @message.update(message_params)
          render json: format_message_response(@message), status: :ok
        else
          render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
        end
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
    end
  end
end
