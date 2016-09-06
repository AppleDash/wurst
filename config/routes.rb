Rails.application.routes.draw do
  root 'urls#index'

  namespace :api do
    resources :urls, only: [:index, :create]
  end
end
