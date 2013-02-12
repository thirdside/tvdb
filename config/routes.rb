Tvdb::Application.routes.draw do
  
  resources :shows do
    resources :seasons do
      resources :episodes
    end
  end

  root :to => 'shows#index'
end
