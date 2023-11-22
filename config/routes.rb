Rails.application.routes.draw do
  resources :board_images
  patch "/ai", to: "application#ai", as: "ai"
  resources :user_selections
  resources :response_records do
    member do
      post "associate_response_image"
      post "remove_response_image"
    end
  end
  root to: "home#index"
  get "home/index"
  devise_for :users
  patch "clear_selection", to: "application#clear_selection", as: "clear_selection"
  patch "croppable/:id", to: "images#croppable", as: "croppable"
  patch "response_images/:id/click", to: "response_images#click", as: "click_response_image"
  patch "response_images/:id/next", to: "response_images#next", as: "next_response_image"
  resources :images do
    post "generate", on: :member
    get "crop", on: :member
    post "purge_saved_images", on: :member
  end
  resources :boards do
    member do
      post "associate_image"
      post "remove_image"
      get "locked"
    end
  end
  resources :board_images do
    get "next"
    get "previous"
  end

  resources :response_boards, only: [:index, :show] do
    member do
      post "associate_response_image"
      post "remove_response_image"
    end
  end
  # post "boards/:board_id/add_image/:image_id", to: "boards#add_image", as: "add_image_to_board"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
end
