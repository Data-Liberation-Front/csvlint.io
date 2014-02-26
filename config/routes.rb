Csvlint::Application.routes.draw do
  
  get "schemas/index"
  root :to => 'validation#index'
  
  get 'validation/list', to: 'validation#list', as: 'list'
  resources :validation 
  resources :schemas
  resources :package
  
end
