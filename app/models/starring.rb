class Starring < ActiveRecord::Base
  belongs_to :actor
  belongs_to :starrable, polymorphic: true
  # attr_accessible :title, :body
end
