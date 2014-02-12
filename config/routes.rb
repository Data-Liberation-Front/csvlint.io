Csvlint::Application.routes.draw do
  
  root :to => 'validation#index'
  
  get 'validation/find_by_url', to: 'validation#find_by_url', as: 'find_by_url'
  resources :validation 
  
end
