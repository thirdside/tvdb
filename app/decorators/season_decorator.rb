class SeasonDecorator < Draper::Decorator
  delegate_all

  def display_name
    source.number.to_s
  end

end
