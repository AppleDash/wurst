class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.string :url
      t.datetime :time
      t.string :server
      t.string :buffer
      t.string :nick

      t.timestamps null: false
    end
  end
end
