Rails.application.routes.draw do
  devise_for :users
  resources :tasks do
    collection do
      get :morning 
    end
  end
  root "tasks#index" 
end
