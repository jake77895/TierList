Rails.application.routes.draw do
  devise_for :users

  # Home view root
  root to: "home#index"
  
end
