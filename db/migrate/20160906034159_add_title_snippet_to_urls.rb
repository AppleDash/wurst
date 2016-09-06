class AddTitleSnippetToUrls < ActiveRecord::Migration
  def change
    add_column :urls, :title, :string
    add_column :urls, :snippet, :string
  end
end
