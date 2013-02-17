Tvdb::Application.routes.draw do
  
  resources :shows do
    resources :seasons do
      resources :episodes
    end
  end

  match "/search/:show/:season/:episode" => "search#url"
  match "/search/:torrent" => "search#torrent", :constraints => {
    :torrent  => /([^\/]+)[^(xml|html|json|xbmc)]/
  }

  root :to => 'shows#index'
end
