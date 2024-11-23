Rails.application.routes.draw do
  devise_for :users

  resources :tier_lists do
    resources :items
  end
  

  # Home view root
  root to: "home#index"
  
end
