class AddSuccessfulJobsToUrls < ActiveRecord::Migration
  def change
    add_column :urls, :successful_jobs, :string
  end
end
