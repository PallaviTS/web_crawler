Rails.application.routes.draw do
  resources :events, only: [:index, :show]
  resources :sites, only: [:new, :create]
  root to: 'events#index'
end
