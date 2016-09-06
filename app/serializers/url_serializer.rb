class UrlSerializer < ActiveModel::Serializer
  attributes :id
  attributes :url, :title, :snippet # URL-related
  attributes :server, :buffer, :nick, :time # IRC-related
  attributes :processing, :successful_jobs
end
