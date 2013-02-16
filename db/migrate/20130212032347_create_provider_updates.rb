class CreateProviderUpdates < ActiveRecord::Migration
  def change
    create_table :provider_updates do |t|

      t.timestamps
    end
  end
end
