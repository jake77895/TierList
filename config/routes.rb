Rails.application.routes.draw do
  devise_for :users

  resources :tier_lists do
    resources :items do
      collection do
        get :filter_items
      end
    end
  
    resources :tier_list_rankings, only: [:create]

    member do
      patch :publish # Adds a PATCH route for the `publish` action
      get 'rank/:item_id', to: 'tier_list_rankings#rank', as: 'rank_item'
    end
  end

  # Home view root
  root to: "home#index"
  
end
