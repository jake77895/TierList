Rails.application.routes.draw do
  devise_for :users

  resources :tier_lists do
    resources :items do
      collection do
        get :filter_items
      end
    end

    resources :comments, only: [:create, :edit, :update, :destroy]
    
    resources :tier_list_rankings, only: [:create]

    member do
      patch :publish # Adds a PATCH route for the `publish` action
      get 'rank/:item_id', to: 'tier_list_rankings#rank', as: 'rank_item'
      
      # Custom routes for the different views
      get 'your_list', to: 'tier_list_rankings#rank', as: 'your_list'
      get :creator_list, to: 'tier_lists#creator_list'
      get :group_list, to: 'tier_lists#group_list'
    end
  end

  # Home view root
  root to: "home#index"
end
