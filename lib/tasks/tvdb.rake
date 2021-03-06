# encoding: utf-8

def update_show(s)
  return unless s
  retriable on: [Timeout::Error], interval: 1 do
    show = Show.where(title: s.title).first_or_create
    show.update_attributes(
      description: s.overview
    )

    # Update Actors
    s.actors.each do |a|
      actor = Actor.where(name: a).first_or_create
      show.actors << actor unless show.actors.include?(actor)
    end

    # Update Episodes
    s.episodes.each do |e|
      season = Season.where(show_id: show, number: e.season_num).first_or_create

      episode = Episode.where(reference_id: e.id).first_or_create

      # Update Actors
      e.guest_stars.split("|").reject(&:empty?).each do |a|
        actor = Actor.where(name: a).first_or_create
        episode.actors << actor unless episode.actors.include?(actor)
      end if e.guest_stars

      puts "Updating #{e.name}"
      episode.update_attributes(
        season:       season,
        description:  e.overview,
        title:        e.name,
        date:         e.first_aired,
        number:       e.episode_num.to_i
      )
    end
  end
end

namespace :tvdb do

  tvdb = Tvdbr::Client.new('918153CC4FEFC92A')
  
  task :update, [:show_title] => :environment do |task, args|
    args.with_default(:show_title => nil)

    shows = args[:show_name] ? Show.where(:title => args[:title]) : Show.all

    shows.each do |show|
      s = tvdb.fetch_series_from_data(title: show.title)
      update_show(s)
    end
  end

  task crawl: :environment do
    last_update = ProviderUpdate.last
    last_date = last_update.try(:updated_at) || last_update.try(:created_at) || Time.at(2.years.ago).to_datetime 
    
    tvdb.each_updated_series(:since => last_date) do |s|
      update_show(s)
    end

    ProviderUpdate.create
  end 
end