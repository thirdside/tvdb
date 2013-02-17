class Show < ActiveRecord::Base
  attr_accessible :description, :title, :seasons

  has_many :seasons, dependent: :destroy
  has_many :episodes, through: :seasons, dependent: :destroy
  
  has_many :starrings, as: :starrable, dependent: :destroy
  has_many :actors, through: :starrings
end
