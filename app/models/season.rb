class Season < ActiveRecord::Base
  attr_accessible :number, :episodes

  belongs_to :show
  
  has_many :episodes, dependent: :destroy
end
