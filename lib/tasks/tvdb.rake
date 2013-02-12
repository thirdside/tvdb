namespace :tvdb do

  task update: :environment do
    tvdb = Tvdbr::Client.new('918153CC4FEFC92A')
    
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

end