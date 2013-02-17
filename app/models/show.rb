class Show < ActiveRecord::Base
  attr_accessible :description, :title, :seasons

  has_many :seasons, dependent: :destroy
  has_many :episodes, through: :seasons, dependent: :destroy
  
  has_many :starrings, as: :starrable, dependent: :destroy
  has_many :actors, through: :starrings

  def serializable_hash(options=nil)
    {
      title: title,
      seasons_count: seasons.count,
      episodes_count: episodes.count
    }
  end
end
