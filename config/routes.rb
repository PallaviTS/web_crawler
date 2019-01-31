Rails.application.routes.draw do
  get 'events', to: 'events#index'
  post 'sites/crawl', to:  'sites#create'
end
