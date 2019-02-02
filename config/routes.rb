Rails.application.routes.draw do
  resources :events, only: [:index, :show]
  post '/sites/crawl', to:  'sites#create'
end
