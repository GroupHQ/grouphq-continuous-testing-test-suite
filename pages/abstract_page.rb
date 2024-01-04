# use utils in RWebSpec and better integration with TestWise
require "#{File.dirname(__FILE__)}/../agileway_utils.rb"

# This is the parent page for all page objects, for operations across all pages, define here
class AbstractPage

  # Optional:
  # provide some general utility functions such as fail_safe { }
  #
  include AgilewayUtils

  # Optional:
  # TestWise Integration, supporting output text to TestWise Console with  puts('message') to TestWise Console
  #
  if defined?(TestWiseRuntimeSupport)
    include TestWiseRuntimeSupport
  end

  def initialize(driver, text = "")
    page_delay
    @driver = driver
    # TODO check the page text contains the given text
  end

  def driver
    @driver
  end

  alias browser driver

  # add delay on landing a web page. the default implementation is using a setting in TestWise IDE
  def page_delay
  end

  def wait_until_animation_completes(animating_element)
    @wait.until {
      element_classes = animating_element.attribute("class")
      animating_class = "ng-animating"
      return true unless element_classes.split(" ").include?(animating_class)
    }

    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      # Ignored
  end

  def member_count_text_pattern
    /\b(\d+) \/ (\d+)\b/
  end
  
  def time_since_text_pattern
    /^\d+\s(?:seconds?|minutes?|hours?) ago$/
  end
  
  def snackbar
    @wait.until { driver.find_element(:css, "mat-snack-bar-container") }
  end
  
  def assert_snackbar_text(expected_text)
    @wait.until do
      snackbar.text.include?(expected_text)
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        # Ignored
    end
  end  
end
