# frozen_string_literal: true

# config/routes/users.rb
Rails.application.routes.draw do
  # Custom user routes
  resources :users do
    member do
      get :delete
    end
    collection do
      get :export
    end
  end
  post 'reset_points', to: 'users#reset_points', as: :reset_points
end
