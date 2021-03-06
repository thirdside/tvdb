class Episode < ActiveRecord::Base
  attr_accessible :description, :title, :number, :date, :season

  belongs_to :season

  has_many :starrings, as: :starrable, dependent: :destroy
  has_many :actors, through: :starrings

  has_one :show, :through => :season

  def as_json(*params)
    {
      :title => title,
      :number => number,
      :description => description,
      :season => season.number,
      :show => show.title
    }
  end
end
