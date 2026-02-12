Rails.application.routes.draw do
  devise_for :users

  root "dashboard#index"

  resources :assets, path: 'my-assets'

  get "up" => "rails/health#show", as: :rails_health_check
end
