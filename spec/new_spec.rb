load File.dirname(__FILE__) + "/../test_helper.rb"

describe "Test Suite" do
  include TestHelper

  before(:all) do
    # browser_type, browser_options, site_url are defined in test_helper.rb
    @driver = $driver = Selenium::WebDriver.for(browser_type, browser_options)
    driver.manage().window().resize_to(1280, 800)
    driver.get(site_url)
  end

  after(:all) do
    driver.quit unless debugging?
  end

  it "Finds at least three active groups" do
    # driver.find_element(...)
    # expect(page_text).to include(..)
    wait = Selenium::WebDriver::Wait.new(:timeout => 9)
    wait.until {
      driver.find_element(:xpath, "//*[@data-test='group-card']")
    }

    elements = driver.find_elements(:xpath, "//*[@data-test='group-card']")
    expect(elements.length).to be >= 3
  end
end
