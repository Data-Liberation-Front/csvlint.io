Csvlint::Application.routes.draw do
  
  root :to => 'validation#index'
  
  get 'validation/find_by_url', to: 'validation#find_by_url', as: 'find_by_url'
  get 'validation/list', to: 'validation#list', as: 'list'
  resources :validation 
  
end
