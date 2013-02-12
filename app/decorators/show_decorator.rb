class ShowDecorator < Draper::Decorator
  delegate_all

  def display_name
    source.title
  end
end
