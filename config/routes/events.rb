# frozen_string_literal: true

# config/routes/events.rb
Rails.application.routes.draw do
  # Event routes
  resources :events do
    resources :attendances, only: [:create] do
      collection do
        get :export
      end
    end
  end
end
