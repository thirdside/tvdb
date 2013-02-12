class Episode < ActiveRecord::Base
  attr_accessible :description, :title, :number, :date

  belongs_to :season
end
