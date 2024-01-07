load File.dirname(__FILE__) + '/../test_helper.rb'

describe "08ComponentLoadingConsistency" do
    include TestHelper
    
    let(:groups_page) { GroupsPage.new(driver) }
    
    before(:all) do
      # browser_type, browser_options, site_url are defined in test_helper.rb
      @driver = $driver = Selenium::WebDriver.for(browser_type, browser_options)
      set_window_size_based_on_viewport_size(driver, :desktop)
      driver.get(site_url)
    end

    after(:all) do
      driver.quit unless debugging?
    end

    it "Should load groups when navigating from GROUPS to another page and back" do
        groups = groups_page.get_groups
        expect(groups.length).to be >= 3
        
        groups_page.click_tab("about", :desktop)
        expect(driver.current_url).to eq("#{site_url}/about")
        
        groups_page.click_tab("groups", :desktop)
        expect(driver.current_url).to eq("#{site_url}/")
        
        groups = groups_page.get_groups
        expect(groups.length).to be >= 3
    end
end


