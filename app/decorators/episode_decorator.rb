class EpisodeDecorator < Draper::Decorator
  delegate_all

  def display_name
    "#{source.number} - #{source.title}"
  end

end
