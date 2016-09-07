require 'selenium-webdriver'
require 'shellwords'
require 'rest-client'
require 'rack/mime'
require 'fileutils'
require 'nokogiri'

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
    @url = Url.find(url_id)
    download_dir = "public/system/urls/#{url_id}/"

    unless File.directory? download_dir
      FileUtils.makedirs download_dir
    end

    perform_actions download_dir

    @url.update processing: false, successful_jobs: @success
  end

  def perform_actions(base_path)
    content_type = perform_action :detect_content_type

    unless content_type
      return
    end

    perform_action :load_in_browser
    perform_action :save_screenshot, File.join(base_path, 'screenshot.png')

    @url.update(
        title: perform_action(:detect_title),
        snippet: perform_action(:detect_description)
    )

    if content_type.downcase == 'text/html' # It's HTML, so we save the page and resources
      perform_action :download_html_page, File.join(base_path, 'html_download/')
    else # Not HTML, so we try to determine a reasonable file extension and save the raw content
      extension = Rack::Mime::MIME_TYPES.invert[content_type.downcase] || '.dat'
      perform_action :download_raw_file, File.join(base_path, "download#{extension}")
    end

    puts @errored

    if @success.include? :load_in_browser
      @browser.quit
    end
  end

  # Perform an action with the given arguments.
  # Stores success of the action or failure reason to relevant member variables.
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
  def detect_content_type
    response = RestClient::Request.execute(:method => :head, :url => @url.url, :headers => {'User-Agent': USER_AGENT}, :verify_ssl => false)

    unless response.code == 200
      raise FetchError, "Received bad response code on initial HEAD: #{response.code}"
    end

    response.headers[:content_type].split(';')[0] || 'text/plain'
  rescue => e
    raise FetchError, "Initial HEAD failed: #{e}"
  end

  # Load the given URL in a Selenium browser and keep it around.
  def load_in_browser
    @browser = WebBrowser.new @url.url
  end

  # Save a screenshot of an actual browser(ish), using PhantomJS
  def save_screenshot(path)
    @browser.save_screenshot @url.url, path
  end

  # Detect the meta description of a URL.
  # If none exists, use the first few words from the page.
  def detect_description
    doc = Nokogiri::HTML @browser.get_html @url.url do |config|
      config.noerror
    end

    doc.css('script, link, style').each { |node| node.remove } # Strip out stuff with text content that isn't actual content

    description = begin
      doc.css('meta[name=description]').attr('value').to_s
    rescue
      doc.css('body').text
          .gsub(/\r|\n|\t/, ' ')
          .squeeze(' ') rescue nil
    end

    description[0..1000]
  end

  # Detect the <title> title of a URL.
  def detect_title
    @browser.get_title(@url.url)[0..250] rescue nil
  end

  # Download a raw file from the given URL to the given path
  def download_raw_file(path)
    wget "-O '#{path.shellescape}' '#{@url.url.shellescape}'"
  end

  # Download the page and all of its assets to the given directory. Convert asset URLs to point to the local directory instead.
  def download_html_page(path)
    wget "--page-requisites --no-host-directories --convert-links --timeout 10 --prefer-family=IPv4 --directory-prefix='#{path.shellescape}' '#{@url.url.shellescape}'"
  end

  def wget(cmdline)
    wget_output = `wget --no-check-certificate --quiet --header='User-Agent: #{USER_AGENT.shellescape}' #{cmdline}`

    unless $?.exitstatus.zero?
      raise FetchError, "wget exited with non-zero code #{$?.exitstatus}:\n#{wget_output}"
    end
  end
end
