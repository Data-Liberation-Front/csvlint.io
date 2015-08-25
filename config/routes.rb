Csvlint::Application.routes.draw do

  get "schemas/index"
  root :to => 'application#index'

  resources :validation
  resources :schemas
  resources :package
  resource :chunk, :only => [:create, :show]

  get 'about', to: 'application#about', as: 'about'
  get 'statistics', to: 'summary#index', as: 'statistics'
  get 'privacy_policy', to: 'application#privacy', as: 'privacy_policy'
  get 'documentation', to: 'application#documentation', as: 'documentation'

end
