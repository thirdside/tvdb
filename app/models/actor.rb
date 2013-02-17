class Actor < ActiveRecord::Base
  has_many :starrings, dependent: :destroy
  
  attr_accessible :name
end
