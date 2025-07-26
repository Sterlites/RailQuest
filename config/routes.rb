# config/routes.rb
# RESTful routes demonstrating Rails routing conventions
Rails.application.routes.draw do
  # Devise routes for authentication
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # Root and static pages
  root 'home#welcome'
  get 'dashboard', to: 'home#dashboard'

  # Main game interface - demonstrates custom routes
  resource :game, only: [:show] do
    member do
      patch :move
      patch :take_item
      patch :use_item
      patch :equip_item
      patch :unequip_item
      patch :rest
      patch :combat
    end
  end

  # Death and respawn system
  get 'death', to: 'game#death'
  patch 'respawn', to: 'game#respawn'

  # RESTful resources
  resources :inventory, only: [:index, :show]
  
  resources :quests, only: [:index, :show] do
    member do
      patch :accept
      patch :abandon
      patch :complete
    end
  end

  resources :combat_logs, only: [:index, :show]

  # API endpoints for future mobile/web app integration
  namespace :api do
    namespace :v1 do
      resources :users, only: [:show, :update] do
        resources :game_sessions, only: [:show, :create, :update]
        resources :inventory, only: [:index]
        resources :quests, only: [:index, :show]
      end
      
      resources :locations, only: [:index, :show]
      resources :items, only: [:index, :show]
    end
  end

  # Admin interface (could be expanded with ActiveAdmin)
  namespace :admin do
    resources :users, only: [:index, :show, :update]
    resources :locations
    resources :items
    resources :quests
    root 'dashboard#index'
  end

  # Health check endpoint for monitoring
  get 'health', to: 'application#health_check'

  # Handle 404s gracefully
  match '*path', to: 'application#not_found', via: :all
end