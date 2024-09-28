Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :applications, param: :application_token, only: [:index, :create, :update, :show] do
        resources :chats, param: :chat_number, only: [:create, :index, :show] do
          resources :messages, param: :message_number, only: [:create, :index, :show, :update] do
            collection do
              get 'search', to: 'messages#search'
            end
          end
        end
      end
    end
  end
end