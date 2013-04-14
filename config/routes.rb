Naskit::Application.routes.draw do
  
  resources :movies

  resources :shows do
    resources :seasons do
      resources :episodes
    end
  end

  match "/search/:show/:season/:episode" => "search#url"
  match "/search" => "search#query"

  root :to => 'shows#index'
end
