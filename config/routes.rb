Rails.application.routes.draw do
  resources :support_sessions, only: [:show, :create] do
    member do
      post :take_step
      post :write
      post :wait
      post :attach
      post :finish
    end
  end

  namespace :chatra do
    post :init
    post :take_step
  end

  root "demo#welcome"
end
