Tvdb::Application.routes.draw do
  
  resources :shows do
    resources :seasons do
      resources :episodes
    end
  end

  match "/search/:query" => "search#search"

  root :to => 'shows#index'
end
