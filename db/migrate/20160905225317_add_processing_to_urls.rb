class AddProcessingToUrls < ActiveRecord::Migration
  def change
    add_column :urls, :processing, :boolean
  end
end
