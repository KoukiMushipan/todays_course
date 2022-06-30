Rails.application.routes.draw do
  root 'landing_pages#top'

  resources :users, except: :new
  get 'signup', to: 'users#new'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

  resources :destinations, only: [:new, :create]
  resources :histories do
    member do
      post :goal
      post :set
    end
  end

  namespace :search do
    scope :departure, as: 'departure' do
      get 'menu', to: 'departures#menu'
      get 'saved', to: 'departures#saved'
      get 'histories', to: 'departures#histories'
      get 'input', to: 'departures#input'
      get 'fix', to: 'departures#fix'
      post 'from_current_location', to: 'departures#from_current_location'
      post 'from_saved', to: 'departures#from_saved'
      post 'from_input', to: 'departures#from_input'
      post 'from_fix', to: 'departures#from_fix'
    end
    scope :destination, as: 'destination' do
      get 'terms', to: 'destinations#terms'
      get 'candidates', to: 'destinations#candidates'
      post 'ready_recommend', to: 'destinations#ready_recommend'
    end
  end
end
