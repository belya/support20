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
    post :take_step
  end

  resources :steps
  resources :support_session_steps

  root "demo#welcome"
end
