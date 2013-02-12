class Episode < ActiveRecord::Base
  attr_accessible :description, :title, :number

  belongs_to :season
end
