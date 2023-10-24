Rails.application.routes.draw do
  root to: "home#index"
  get "home/index"
  devise_for :users
  resources :images do
    post "speak", on: :member
    post "generate", on: :member
  end
  resources :boards do
    member do
      post "associate_image"
      post "remove_image"
      get "locked"
    end
  end
  # post "boards/:board_id/add_image/:image_id", to: "boards#add_image", as: "add_image_to_board"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
