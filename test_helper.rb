# require 'rubygems'
gem "selenium-webdriver"
require "selenium-webdriver"
require "rspec"

# include utility functions such as 'page_text', 'try_for', 'fail_safe', ..., etc.
require "#{File.dirname(__FILE__)}/agileway_utils.rb"

# this loads defined page objects under pages folder
require "#{File.dirname(__FILE__)}/pages/abstract_page.rb"
Dir["#{File.dirname(__FILE__)}/pages/*_page.rb"].each { |file| load file }

# The default base URL for running from command line or continuous build process
$BASE_URL = "https://localhost"

# This is the helper for your tests, every test file will include all the operations
# defined here.

# ver 1.3 change :capabilities => :options (for Chrome and Edge)

module TestHelper
  include AgilewayUtils
  if defined?(TestWiseRuntimeSupport) # TestWise 5+
    include TestWiseRuntimeSupport
  end

  def browser_type
    if $TESTWISE_BROWSER
      $TESTWISE_BROWSER.downcase.to_sym
    elsif ENV["BROWSER"]
      ENV["BROWSER"].downcase.to_sym
    else
      :chrome
    end
  end

  alias the_browser browser_type

  def site_url(default = $BASE_URL)
    $TESTWISE_PROJECT_BASE_URL || ENV["BASE_URL"] || default
  end

  def browser_options
    the_browser_type = browser_type.to_s

    if the_browser_type == "chrome"
      the_chrome_options = Selenium::WebDriver::Chrome::Options.new
      # make the same behaviour as Python/JS
      # leave browser open until calls 'driver.quit'

      # Up to Selenium v4.10 not w3c compliant: {"detach"=>true}
      # the_chrome_options.addOption("detach", "true")

      the_chrome_options.detach = true

      # if Selenium unable to detect Chrome browser in default location
      if ENV["ALTERNATIVE_CHROME_PATH"]
        the_chrome_options.binary = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
      end

      if $TESTWISE_BROWSER_HEADLESS || ENV["BROWSER_HEADLESS"] == "true"
        # the_chrome_options.add_argument("--headless")
        #

        # Between Chrome versions 96 to 108 it was --headless=chrome, after version 109 --headless=new.
        # reference:   https://www.selenium.dev/blog/2023/headless-is-going-away/
        the_chrome_options.add_argument("--headless=new")
      end

      if defined?(TestWiseRuntimeSupport)
        browser_debugging_port = get_browser_debugging_port() rescue 19218 # default port
        puts("Enabled chrome browser debug port: #{browser_debugging_port}")
        the_chrome_options.add_argument("--remote-debugging-port=#{browser_debugging_port}")
      else
        # puts("Chrome debugging port not enabled.")
      end

      if defined?(TestwiseListener)
        return :options => the_chrome_options, :listener => TestwiseListener.new
      else
        return :options => the_chrome_options
      end
    elsif the_browser_type == "firefox"
      the_firefox_options = Selenium::WebDriver::Firefox::Options.new
      if $TESTWISE_BROWSER_HEADLESS || ENV["BROWSER_HEADLESS"] == "true"
        the_firefox_options.headless!
        # the_firefox_options.add_argument("--headless") # this works too
      end

      # the_firefox_options.add_argument("--detach") # does not work

      return :options => the_firefox_options
    elsif the_browser_type == "ie"
      the_ie_options = Selenium::WebDriver::IE::Options.new
      if $TESTWISE_BROWSER_HEADLESS || ENV["BROWSER_HEADLESS"] == "true"
        # not supported yet?
        # the_ie_options.add_argument('--headless')
      end
      return :options => the_ie_options
    elsif the_browser_type == "edge"
      the_edge_options = Selenium::WebDriver::Edge::Options.new
      the_edge_options.detach = true

      if $TESTWISE_BROWSER_HEADLESS || ENV["BROWSER_HEADLESS"] == "true"
        the_edge_options.add_argument("--headless")
      end

      if defined?(TestWiseRuntimeSupport)
        browser_debugging_port = get_browser_debugging_port() rescue 19218 # default port
        puts("Enabled edge browser debug port: #{browser_debugging_port}")
        the_edge_options.add_argument("--remote-debugging-port=#{browser_debugging_port}")
      else
        # puts("Chrome debugging port not enabled.")
      end

      return { :options => the_edge_options }
    else
      return {}
    end
  end

  def driver
    @driver
  end

  def browser
    @driver
  end

  # go to path based on current base url
  def visit(path)
    driver.navigate.to(site_url + path)
  end

  def page_text
    driver.find_element(:tag_name => "body").text
  end

  def debugging?
    return ENV["RUN_IN_TESTWISE"].to_s == "true" && ENV["TESTWISE_RUNNING_AS"] == "test_case"
  end

  ##
  #  Highlight a web control on a web page, currently supports only 'background_color'
  #  - elem,
  #  - options, a hashmap,
  #      :background_color
  #      :duration,  in seconds
  #
  #  Example:
  #   highlight_control(driver.find_element(:id, "username"), {:background_color => '#02FE90', :duration => 5})
  def highlight_control(element, opts = {})
    return if element.nil?
    background_color = opts[:background_color] ? opts[:background_color] : "#FFFF99"
    duration = (opts[:duration].to_i * 1000) rescue 2000
    duration = 2000 if duration < 100 || duration > 60000
    driver.execute_script("h = arguments[0]; h.style.backgroundColor='#{background_color}'; window.setTimeout(function () { h.style.backgroundColor = ''}, #{duration})", element)
  end

  # prevent extra long string generated test scripts that blocks execution when running in
  # TestWise or BuildWise Agent
  def safe_print(str)
    return if str.nil? || str.empty?
    if (str.size < 250)
      puts(str)
      return
    end

    if ENV["RUN_IN_TESTWISE"].to_s == "true" && ENV["RUN_IN_BUILDWISE_AGENT"].to_s == "true"
      puts(str[0..200])
    end
  end

  ## user defined functions
  # View Angular CDK Breakpoints here: https://github.com/angular/components/blob/cfc8a872c195b668c6acd022d1d5c414777f3971/src/cdk/layout/layout.md#L3
  # Ranges are [min-width, max-width), i.e. max-width is not inclusive in the range
  def breakpoints
    {
      "Handset" => {
        "portrait" => {
          "min-width" => nil,
          "max-width" => 600,
        },
        "landscape" => {
          "min-width" => nil,
          "max-width" => 960,
        },
      },
      "Tablet" => {
        "portrait" => {
          "min-width" => 600,
          "max-width" => 839.98,
        },
        "landscape" => {
          "min-width" => 960,
          "max-width" => 1279.98,
        },
      },
      "Web" => {
        "portrait" => {
          "min-width" => 840,
          "max-width" => nil,
        },
        "landscape" => {
          "min-width" => 1280,
          "max-width" => nil,
        },
      },
    }
  end

  def width_with_height(width, portrait = false)
    return portrait ? [width, width + 100] : [width, width - 100]
  end

  def handset_viewport_dimensions(portrait = false)
    handset_breakpoints = breakpoints["Handset"]

    pixel_breakpoint = if portrait
        handset_breakpoints["portrait"]["max-width"]
      else
        handset_breakpoints["landscape"]["max-width"]
      end

    width_with_height(pixel_breakpoint - 1, portrait)
  end

  def tablet_viewport_dimensions(portrait = false)
    tablet_breakpoints = breakpoints["Tablet"]
    pixel_breakpoint_average = nil

    pixel_breakpoint_average = if (portrait)
        pixel_breakpoint_min = tablet_breakpoints["portrait"]["min-width"]
        pixel_breakpoint_max = tablet_breakpoints["portrait"]["max-width"]
        (pixel_breakpoint_min + pixel_breakpoint_max) / 2
      else
        pixel_breakpoint_min = tablet_breakpoints["landscape"]["min-width"]
        pixel_breakpoint_max = tablet_breakpoints["landscape"]["max-width"]
        (pixel_breakpoint_min + pixel_breakpoint_max) / 2
      end

    width_with_height(pixel_breakpoint_average, portrait)
  end

  def web_viewport_dimensions(portrait = false)
    web_breakpoints = breakpoints["Web"]

    pixel_breakpoint = if (portrait)
        pixel_breakpoint = web_breakpoints["portrait"]["min-width"]
      else
        pixel_breakpoint = web_breakpoints["landscape"]["min-width"]
      end

    puts width_with_height(pixel_breakpoint, portrait)
    width_with_height(pixel_breakpoint, portrait)
    [1280, 800]
  end

  def get_viewport_dimensions_for(screen_type)
    case screen_type
    when :desktop
      web_viewport_dimensions
    when :tablet
      tablet_viewport_dimensions
    when :handset
      handset_viewport_dimensions
    else
      raise "No dimensions available for screen type: #{screen_type}"
    end
  end

  def set_window_size_based_on_viewport_size(driver, screen_type)
    viewport_dimensions = get_viewport_dimensions_for(screen_type)
    
    desired_viewport_width = viewport_dimensions[0]
    desired_viewport_height = viewport_dimensions[1]

    driver.manage.window.resize_to(desired_viewport_width, desired_viewport_height)

    current_viewport_width = driver.execute_script("return window.innerWidth;")
    current_viewport_height = driver.execute_script("return window.innerHeight;")

    width_difference = desired_viewport_width - current_viewport_width
    height_difference = desired_viewport_height - current_viewport_height

    driver.manage.window.resize_to(desired_viewport_width + width_difference, desired_viewport_height + height_difference)
  end
end
