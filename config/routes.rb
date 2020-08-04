Rails.application.routes.draw do
  root to: 'static#home'
  get 'static/home'

  resources :countries, only: :show, param: :name
end
