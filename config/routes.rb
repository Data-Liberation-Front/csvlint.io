Csvlint::Application.routes.draw do
  
  get "schemas/index"
  root :to => 'application#index'
  
  resources :validation 
  resources :schemas
  resources :package
  
  get 'about', to: 'application#about', as: 'about'
    
end
