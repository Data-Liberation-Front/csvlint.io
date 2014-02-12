Csvlint::Application.routes.draw do
  
  root :to => 'validation#index'
  
  resources :validation 
  get 'validation/by_url', to: 'validation#url'
  
end
