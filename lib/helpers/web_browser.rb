require 'selenium-webdriver'

# Represents a virtual web browser being driven by code, loading web pages and providing programmatic access to them.
class WebBrowser
  def initialize(url = nil)
    @driver = Selenium::WebDriver.for :phantomjs, :args => '--ignore-ssl-errors=true'
    @driver.manage.window.resize_to 1920, 1080
    load_url(url) if url
  end

  # Load a URL in the browser, if it isn't already loaded
  def load_url(url)
    if @current_url != url
      @current_url = url
      @driver.navigate.to url
      sleep 0.5
    end
  end

  # Save a screenshot of the given URL to the given path
  def save_screenshot(url, path)
    load_url url
    @driver.save_screenshot path
  end

  # Get the title of the given URL
  def get_title(url)
    load_url url
    @driver.title
  end

  # Get the raw page source of the given URL
  def get_html(url)
    load_url url
    @driver.page_source
  end

  # Close the virtual browser
  def quit
    @driver.quit
  end
end
