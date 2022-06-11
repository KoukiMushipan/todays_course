Rails.application.routes.draw do
  root 'landing_pages#top'

  resources :users, except: :new
  get 'signup', to: 'users#new'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

  scope :search, as: 'search' do
    get 'destination', to: 'searches#destination'
    get 'candidates', to: 'searches#candidates'
    get 'route', to: 'searches#route'

    scope :departure, as: 'departure' do
      get 'menu', to: 'departures#menu'
      get 'saved', to: 'departures#saved'
      get 'histories', to: 'departures#histories'
      get 'input', to: 'departures#input'

      post 'from_current_location', to: 'departures#from_current_location'
      post 'from_saved', to: 'departures#from_saved'
      post 'from_address', to: 'departures#from_address'
    end
  end

end
