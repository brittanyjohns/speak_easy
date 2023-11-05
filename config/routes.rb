Rails.application.routes.draw do
  get "response_boards/index"
  get "response_boards/show"
  root to: "home#index"
  get "home/index"
  devise_for :users
  patch "croppable/:id", to: "images#croppable", as: "croppable"
  patch "response_images/:id/click", to: "response_images#click", as: "click_response_image"
  resources :images do
    post "generate", on: :member
    get "create_response_board", on: :member
    get "crop", on: :member
  end
  resources :boards do
    member do
      post "associate_image"
      post "remove_image"
      get "locked"
    end
  end

  resources :response_boards, only: [:index, :show]
  # post "boards/:board_id/add_image/:image_id", to: "boards#add_image", as: "add_image_to_board"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
