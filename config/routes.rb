Rails.application.routes.draw do
  devise_for :users
  resources :customers
  root "home#index"


  resources :customers do
    
    collection { post :customers_reset }
    collection { post :customers_import }
    collection { post :customers_action }
    
    collection do
      post "customers_reset"
      post "customers_delete"
    end
    member do
      post "customer_call"
    end
  end

  # get "up" => "rails/health#show", as: :rails_health_check
end
