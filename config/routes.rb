Rails.application.routes.draw do
  devise_for :users

  root "dashboard#index"

  resources :assets, path: 'my-assets'
  post '/ask', to: 'ai_chats#create', as: 'ask_ai'  # ← Add this

  get "up" => "rails/health#show", as: :rails_health_check
end
