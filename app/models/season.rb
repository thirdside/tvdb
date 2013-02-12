class Season < ActiveRecord::Base
  attr_accessible :title

  belongs_to :show
  
  has_many :episodes, dependent: :destroy
end
