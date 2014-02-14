Csvlint::Application.routes.draw do
  
  get "schemas/index"
  root :to => 'validation#index'
  
  get 'validation/find_by_url', to: 'validation#find_by_url', as: 'find_by_url'
  get 'validation/list', to: 'validation#list', as: 'list'
  resources :validation 
  resources :schemas
  
end
