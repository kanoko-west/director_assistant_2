Rails.application.routes.draw do
  devise_for :users
  resources :tasks do
    collection do
      get :morning
      get :master
    end
    member do
      patch :archive
      patch :update_status
    end
  end
  root "tasks#index" 
end
