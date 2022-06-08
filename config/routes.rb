Rails.application.routes.draw do
  root 'landing_pages#top'

  resources :users, except: :new
  get 'signup', to: 'users#new'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
end
