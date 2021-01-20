Rails.application.routes.draw do
  resources :products do 
    collection do
      post 'scrapper'
    end
  end
  root 'products#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
