class SearchController < ApplicationController
  
  def url
    search(params[:show], params[:season], params[:episode])
  end

  def query
    if params[:q].present?
      
      # is this a tv show in torrent format?
      if torrent = params[:q].match(/(?<show>.+)\.[sS]?(?<season>\d+)[eExX](?<episode>\d+)/)
        show      = torrent["show"].split(".").join(" ")
        season    = torrent["season"].to_i
        episode   = torrent["episode"].to_i

        search_episode(show, season, episode)
      else
        search_movie_or_episode(params[:q])
      end

    end
  end

  protected

  def search_movie_or_episode name
    if resource = Movie.where(title: name).first
      redirect_to movie_path(resource, format: params[:format]), status: 301
    elsif resource = Episode.where(title: name).first
      redirect_to show_season_episode_path(resource.show, resource.season, resource, format: params[:format]), status: 301
    else
      render :text => nil, :status => 404
    end
  end

  def search_episode show, season, episode
    show      = Show.where("lower(title) LIKE ?", show.downcase).first_or_initialize
    season    = show.seasons.where(number: season).first_or_initialize
    
    if episode = season.episodes.where(number: episode).first
      redirect_to show_season_episode_path(show, season, episode, format: params[:format]), status: 301
    else
      render :text => nil, :status => 404
    end
  end
end
