class SearchController < ApplicationController
  
  def url
    search(params[:show], params[:season], params[:episode])
  end

  def torrent
    if params[:torrent]
      torrent = params[:torrent].match(/(?<title>.+)\.S?(?<season>\d{2})E?(?<episode>\d{2})/)

      # sanitize a bit...
      title     = torrent["title"].split(".").join(" ")
      season    = torrent["season"].to_i
      episode   = torrent["episode"].to_i

      search(title, season, episode)
    end
  end

  protected

  def search show, season, episode
    show      = Show.where(title: show).first_or_initialize
    season    = show.seasons.where(number: season).first_or_initialize
    
    if episode = season.episodes.where(number: episode).first
      redirect_to show_season_episode_path(show, season, episode, format: params[:format]), status: 301
    else
      render :text => nil, :status => 404
    end
  end
end
