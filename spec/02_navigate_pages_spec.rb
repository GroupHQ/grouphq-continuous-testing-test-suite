load File.dirname(__FILE__) + "/../test_helper.rb"

describe "Navigate Pages" do
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

  def self.general_device_tests(screen_type)
    context "on a #{screen_type} screen size" do
      before(:all) do
        set_window_size_based_on_viewport_size(driver, screen_type)
      end
      
      before(:each) do
        sleep 0.2 # respect server rate limit
        groups_page.click_logo(screen_type) # resets page to GROUPS
      end  

      it "Should navigate to the ABOUT page when the ABOUT tab is clicked" do
        groups_page.click_tab("about", screen_type)
        expect(driver.current_url).to eq("#{site_url}/about")
      end

      it "Should navigate to the SOURCES page when the SOURCES tab is clicked" do
        groups_page.click_tab("sources", screen_type)
        expect(driver.current_url).to eq("#{site_url}/sources")
      end

      it "Should navigate to the GROUPS page when the GROUPS tab is clicked" do
        groups_page.click_tab("groups", screen_type)
        expect(driver.current_url).to eq("#{site_url}/")
      end

      it "Should navigate to the GROUPS page when the page logo is clicked" do
        groups_page.click_logo(screen_type)
        expect(driver.current_url).to eq("#{site_url}/")
      end
    end
  end

  def self.menu_nav_type_tests(screen_type)
    context "on a #{screen_type} screen size" do
      before(:all) do
        set_window_size_based_on_viewport_size(driver, screen_type)
      end
      
      before(:each) do
        sleep 1 # respect server rate limit
        driver.navigate.refresh # resets menu state to default
      end  
      
      it "should have the menu closed by default" do
        expect(groups_page.is_nav_menu_hidden?).to be true
      end

      it "should allow the menu to be toggled open" do
        groups_page.click_nav_menu
        expect(groups_page.is_nav_menu_displayed?).to be true
      end

      it "should allow the menu to be toggled closed" do
        groups_page.click_nav_menu
        expect(groups_page.is_nav_menu_displayed?).to be true

        groups_page.click_nav_menu
        expect(groups_page.is_nav_menu_hidden?).to be true
      end
    end
  end

  general_device_tests(:desktop)
  general_device_tests(:tablet)
  general_device_tests(:handset)

  menu_nav_type_tests(:tablet)
  menu_nav_type_tests(:handset)
end
