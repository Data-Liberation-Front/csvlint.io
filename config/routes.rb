Csvlint::Application.routes.draw do

  get "schemas/index"
  root :to => 'application#index'

  resources :validation
  resources :schemas
  resources :package

  get 'about', to: 'application#about', as: 'about'
  get 'statistics', to: 'summary#index', as: 'statistics'
  get 'privacy_policy', to: 'application#privacy', as: 'privacy_policy'
  get 'documentation', to: 'application#documentation', as: 'documentation'

  mount ResumableUpload::Engine => "/upload"

end
