Rails.application.routes.draw do
  resources :menus do
    resources :docs do
      member do
        get :enhance_image_description
      end
    end
  end
  patch "/ai", to: "application#ai", as: "ai"
  root to: "home#index"
  get "home/index"
  devise_for :users
  resources :users, only: [:index, :show, :edit, :update] do
    member do
      patch "update_selection"
    end
  end
  resources :response_records do
    member do
      post "associate_response_image"
      post "remove_response_image"
    end
  end

  resources :images do
    post "find_or_create", on: :collection
    post "run_image_setup", on: :collection
    get "edit_multiple", on: :collection
    patch "update_multiple", on: :collection
    post "generate", on: :member
    get "crop", on: :member
    patch "croppable", on: :member
    post "purge_saved_images", on: :member
    post "describe", on: :member
  end
  resources :boards do
    member do
      patch "mark_as_favorite"
      patch "unfavorite"
      get "build"
      post "add_multiple_images"
      post "associate_image"
      post "remove_image"
      get "locked"
    end
  end
  resources :board_images do
    member do
      get "next"
      get "previous"
      patch "click"
    end
  end

  resources :response_boards, only: [:index, :show] do
    member do
      post "associate_response_image"
      post "remove_response_image"
    end
  end

  resources :response_images do
    member do
      get "next"
      get "previous"
      patch "click"
    end
  end

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
end
