Rails.application.routes.draw do
  resources :support_sessions, only: [:show, :create] do
    member do
      post :predict
      post :write
      post :wait
      post :attach
      post :finish
    end
  end
end
