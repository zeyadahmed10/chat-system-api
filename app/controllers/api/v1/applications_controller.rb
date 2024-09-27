module Api
    module V1
      class ApplicationsController < ApplicationController
        before_action :set_application, only: [:update, :show]
        
        def index
          @applications = Application.all
          render json: @applications, only: [:name, :application_token, :chats_count], status: :ok
        end

        def create
          @application = Application.new(application_params)
          if @application.save
            render json: { token: @application.application_token, chats_count: @application.chats_count }, status: :created
          else
            render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        def update
          if @application.update(application_params)
            render json: { name: @application.name, token: @application.application_token, chats_count: @application.chats_count }, status: :ok
          else
            render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
          end
        end
  
        def show
          render json: { name: @application.name, token: @application.application_token, chats_count: @application.chats_count }, status: :ok
          
        end
  
        private
  
        def set_application
          @application = Application.find_by(application_token: params[:application_token])
          render json: { error: 'Application not found' }, status: :not_found unless @application
        end
  
        def application_params
          params.require(:application).permit(:name)
        end

      end
    end
  end
  