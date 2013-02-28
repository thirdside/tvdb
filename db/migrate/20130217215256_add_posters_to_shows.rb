class AddPostersToShows < ActiveRecord::Migration
  def change
    add_attachment :shows, :poster
  end
end
