Rails.application.routes.draw do
  root 'current_user#index'
  get 'me', to: 'current_user#index'

  namespace :api do
    namespace :v1 do
      resources :users, only: [:show] do
        member do
          post "friend"
          post "unfriend"
        end
      end
    end
  end

  devise_scope :user do
    post 'jwt', to: 'users/sessions#jwt'
  end
  devise_for :users,
             path: '',
             defaults: { format: :json },
             path_names: {
                sign_in: 'login',
                sign_out: 'logout',
                registration: 'signup'
             },
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  match '*path', to: 'application#error404', via: :all
end
