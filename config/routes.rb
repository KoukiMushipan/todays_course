Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get 'top', to: 'homes#top'
  get 'terms', to: 'homes#terms'

  resources :guests, only: %i[index new]

  get 'signup', to: 'users#new'
  resources :users, only: %i[create]
  resource :profile, only: %i[show edit update destroy] do
    get 'cancel'
  end

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

  resources :searches, only: %i[index new create]
  resources :departures
  root 'departures#new'
  resources :destinations, only: %i[new create show edit update destroy]
  resources :histories, only: %i[new create show edit update destroy] do
    get 'cancel', on: :member
  end
end
