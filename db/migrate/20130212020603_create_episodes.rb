class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.references  :season
      t.string      :number
      t.string      :title
      t.text        :description
      t.datetime    :date
      t.integer     :duration
      t.timestamps
    end
  end
end
