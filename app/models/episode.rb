class Episode < ActiveRecord::Base
  attr_accessible :description, :title, :number, :date, :season

  belongs_to :season
  has_many :starrings, as: :starrable, dependent: :destroy
  has_many :actors, through: :starrings
end
