Rails.application.routes.draw do
  devise_for :users
  resources :tasks do
    collection do
      get :morning
    end
    member do
      patch :archive  # これにより archive_task_path(task) が使えるようになります 
    end
  end
  root "tasks#index" 
end
