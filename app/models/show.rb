class Show < ActiveRecord::Base
  attr_accessible :description, :title

  has_many :seasons, dependent: :destroy
  has_many :episodes, through: :seasons, dependent: :destroy
end
