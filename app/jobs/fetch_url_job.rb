require 'selenium-webdriver'
require 'shellwords'
require 'rest-client'
require 'rack/mime'
require 'fileutils'

# Disabling of certificate checking throughout this class is due to the fact that I want to grab as many links as
# possible, and some links may not have valid certificates.

class FetchError < Exception
end

class FetchUrlJob < ActiveJob::Base
  USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36'

  def initialize(*args)
    super
    @attempted = []
    @success = []
    @errored = {}
  end

  def perform(url_id)
    url = Url.find(url_id)
    download_dir = "public/system/urls/#{url.id}/"

    unless File.directory? download_dir
      FileUtils.makedirs download_dir
    end

    perform_actions url.url, download_dir

    url.successful_jobs = @success
    url.processing = false
    url.save
  end

  def perform_actions(url, base_path)
    content_type = perform_action :detect_content_type, url

    unless content_type
      return
    end

    perform_action :save_screenshot, url, File.join(base_path, 'screenshot.png')
    if content_type.downcase == 'text/html'
      perform_action :download_html_page, url, File.join(base_path, 'html_download/')
    else
      extension = Rack::Mime::MIME_TYPES.invert[content_type.downcase] || '.dat'

      perform_action :download_raw_file, url, File.join(base_path, "download#{extension}")
    end
  end

  def perform_action(action, *args)
    @attempted << action
    begin
      result = self.send action, *args
      @success << action
      result
    rescue Exception => e
      @errored[action] = e.to_s
      nil
    end
  end

  # Detect the content type of a URL with a HEAD request
  def detect_content_type(url)
    response = RestClient::Request.execute(:method => :head, :url => url, :headers => {'User-Agent': USER_AGENT}, :verify_ssl => false)

    unless response.code == 200
      raise FetchError, "Received bad response code on initial HEAD: #{response.code}"
    end

    return response.headers[:content_type].split(';')[0] || 'text/plain'
  rescue => e
    raise FetchError, "Initial HEAD failed: #{e}"
  end

  # Save a screenshot of an actual browser(ish), using PhantomJS
  def save_screenshot(url, path)
    driver = Selenium::WebDriver.for :phantomjs, :args => '--ignore-ssl-errors=true'
    driver.manage.window.resize_to 1920, 1080
    driver.navigate.to url
    driver.save_screenshot path
    driver.quit
  end

  # Download a given raw file from a URL to the given path
  def download_raw_file(url, path)
    wget "-O '#{path.shellescape}' '#{url.shellescape}'"
  end

  # Download the page and all of its assets to the given directory. Convert asset URLs to point to the local directory instead.
  def download_html_page(url, path)
    wget "--page-requisites --no-host-directories --convert-links --timeout 10 --prefer-family=IPv4 --directory-prefix='#{path.shellescape}' '#{url.shellescape}'"
  end

  def wget(cmdline)
    wget_output = `wget --no-check-certificate --quiet --header='User-Agent: #{USER_AGENT.shellescape}' #{cmdline}`

    unless $?.exitstatus.zero?
      raise FetchError, "wget exited with non-zero code #{$?.exitstatus}:\n#{wget_output}"
    end
  end
end