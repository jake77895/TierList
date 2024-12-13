Rails.application.routes.draw do
  resources :pages
  devise_for :users

  resources :tier_list_templates

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

  resources :pages do
    member do
      get :tier_lists # A page-specific tier list view
    end
  
    post :associate_tier_list
    delete :dissociate_tier_list
  end

  # Article path
  get 'articles/:id', to: 'articles#show', as: 'article'
end
