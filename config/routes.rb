Tvdb::Application.routes.draw do
  
  resources :shows do
    resources :seasons do
      resources :episodes
    end
  end

  match "/search/:show/:season/:episode" => "search#url"
  match "/search/:torrent" => "search#torrent", :constraints => { :torrent => /([^\/]+)[^#{Mime::EXTENSION_LOOKUP.keys.join('|')}]/ }

  root :to => 'shows#index'
end
