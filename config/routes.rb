Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get 'signup', to: 'users#new'
  resources :users, only: %i[create]
  resource :profile, only: %i[show edit update destroy]
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

  namespace :search do
    resources :departures, only: %i[new create]
    resources :destinations, only: %i[index new create]
  end

  resources :destinations, only: %i[new create]
end
