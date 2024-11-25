Rails.application.routes.draw do
  devise_for :users

  resources :tier_lists do
    resources :items
    member do
      patch :publish # Adds a PATCH route for the `publish` action
      get :rank
    end
  end

  # Tier list ranking
  resources :tier_list_rankings, only: [:create]


  

  # Home view root
  root to: "home#index"
  
end
