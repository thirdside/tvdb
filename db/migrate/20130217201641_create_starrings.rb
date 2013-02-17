class CreateStarrings < ActiveRecord::Migration
  def change
    create_table :starrings do |t|
      t.references :starrable, polymorphic: true
      t.references :actor
      t.timestamps
    end
  end
end
