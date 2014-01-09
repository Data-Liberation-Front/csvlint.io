Csvlint::Application.routes.draw do
  
  root :to => 'validation#index'
  post '/validate' => 'validation#redirect'
  get '/validate' => 'validation#validate', :as => 'validation'
  
end
