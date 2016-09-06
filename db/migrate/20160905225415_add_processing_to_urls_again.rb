class AddProcessingToUrlsAgain < ActiveRecord::Migration
  def change
    remove_column :urls, :processing
    add_column :urls, :processing, :boolean, default: true
  end
end
