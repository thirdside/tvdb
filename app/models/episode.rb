class Episode < ActiveRecord::Base
  attr_accessible :description, :title

  belongs_to :season
end
