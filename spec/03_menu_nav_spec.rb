load File.dirname(__FILE__) + "/../test_helper.rb"

describe "03MenuNav" do
  include TestHelper

  let(:groups_page) { GroupsPage.new(driver) }

  before(:all) do
    # browser_type, browser_options, site_url are defined in test_helper.rb
    @driver = $driver = Selenium::WebDriver.for(browser_type, browser_options)
    driver.navigate.to(site_url)
  end

  after(:all) do
    driver.quit unless debugging?
  end

  def self.menu_nav_type_tests(screen_type)
    context "on a #{screen_type} screen size" do
      before(:each) do
        set_window_size_based_on_viewport_size(driver, screen_type)
      end

      it "should have the menu closed by default" do
        expect(groups_page.wait_until_nav_menu_hidden?).to be true
      end

      it "should allow the menu to be toggled open" do
        groups_page.click_nav_menu
        expect(groups_page.wait_until_nav_menu_displayed?).to be true
      end

      it "should allow the menu to be toggled closed" do
        groups_page.click_nav_menu unless groups_page.nav_menu_displayed?
        expect(groups_page.wait_until_nav_menu_displayed?).to be true

        groups_page.click_nav_menu
        expect(groups_page.wait_until_nav_menu_hidden?).to be true
      end
    end
  end

  menu_nav_type_tests(:tablet)
  menu_nav_type_tests(:handset)
end
