Tvdb::Application.routes.draw do
  
  resources :shows do
    resources :seasons do
      resources :episodes
    end
  end

  match "/search/:torrent" => "search#torrent", :constraints => { :torrent => /[^\/]+/ }

  root :to => 'shows#index'
end
