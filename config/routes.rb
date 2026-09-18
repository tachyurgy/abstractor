Rails.application.routes.draw do
  root "encounters#index"
  resources :encounters, only: [:index, :show, :new, :create] do
    member do
      post :code       # run the coding agent
      post :finalize
    end
    resources :code_proposals, only: [:create]
  end
  resources :code_proposals, only: [] do
    member do
      patch :accept
      patch :reject
      patch :reopen
    end
  end
  resources :evals, only: [:index, :create]
  get "rules", to: "rules#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
