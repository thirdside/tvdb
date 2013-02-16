class Episode < ActiveRecord::Base
  attr_accessible :description, :title, :number, :date, :season

  belongs_to :season
end
