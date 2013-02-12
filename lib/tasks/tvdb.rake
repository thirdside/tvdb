namespace :tvdb do

  tvdb = Tvdbr::Client.new('918153CC4FEFC92A')

  task update: :environment do
    Show.all.each do |show|
      s = tvdb.fetch_series_from_data(title: show.title)
      show.description = s.overview
      show.save
      s.episodes.each do |e|
        episode = Episode.where(reference_id: e.id).first_or_create
        puts "Updating #{e.name}"
        episode.update_attributes(
          description:  e.overview,
          title:        e.name,
          date:         e.first_aired,
          number:       e.episode_num.to_i
        )
      end
    end
  end

  task crawl: :environment do
    last_update = ProviderUpdate.last
    last_date = last_update.try(:updated_at) || last_update.try(:created_at) || Time.at(2.years.ago).to_datetime 
    
    tvdb.each_updated_series(:since => last_date) do |s|
      retriable on: [Timeout::Error], interval: 1 do
        show = Show.where(title: s.title).first_or_create
        show.update_attributes(
          description: s.overview
        )

        s.episodes.each do |e|

          season = Season.where(show_id: show, number: e.season_num).first_or_create

          episode = Episode.where(reference_id: e.id).first_or_create
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

    ProviderUpdate.create
  end

end