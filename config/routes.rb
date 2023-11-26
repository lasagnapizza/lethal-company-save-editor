Rails.application.routes.draw do
  root to: "saves#index"

  get "up" => "rails/health#show", :as => :rails_health_check

  resources :users, only: [:new, :create, :edit, :update]
  resources :sessions, only: [:new, :create] do
    collection do
      delete :destroy
    end
  end

  resources :saves do
    member do
      get :download
    end
  end
end
