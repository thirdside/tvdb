class Movie < ActiveRecord::Base
  attr_accessible :description, :title

  has_many :starrings, as: :starrable, dependent: :destroy
  has_many :actors, through: :starrings
end
