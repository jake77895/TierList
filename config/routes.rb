Rails.application.routes.draw do
  resources :tier_lists
  devise_for :users

  # Home view root
  root to: "home#index"
  
end
