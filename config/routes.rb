Rails.application.routes.draw do
  get 'currencies/update'
  devise_for :users

  root "dashboard#index"

  resources :assets, path: 'my-assets'
  post '/ask', to: 'ai_chats#create', as: 'ask_ai'
  patch '/currency', to: 'currencies#update', as: 'update_currency'

  get "up" => "rails/health#show", as: :rails_health_check
end
