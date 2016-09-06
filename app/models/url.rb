class Url < ActiveRecord::Base
  validates_presence_of :url
  validates_presence_of :time
  validates_presence_of :server
  validates_presence_of :buffer
  validates_presence_of :nick

  def successful_jobs=(jobs)
    if jobs.is_a? Array
      self[:successful_jobs] = jobs.join ','
    else
      self[:successful_jobs] = jobs.to_s
    end
  end

  def successful_jobs
    if self[:successful_jobs]
      self[:successful_jobs].split ','
    else
      []
    end
  end
end
