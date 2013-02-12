class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.references  :show
      t.integer     :number
      t.timestamps
    end
  end
end
