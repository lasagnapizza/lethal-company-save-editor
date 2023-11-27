Rails.application.routes.draw do
  root to: "pages#index"

  get "up" => "rails/health#show", :as => :rails_health_check

  get "/help", to: "pages#help"

  resources :users, except: [:index, :destroy]
  resources :sessions, only: [:new, :create] do
    collection do
      delete :destroy
    end
  end

  resources :saves do
    member do
      post :download
    end
  end
end
