load File.dirname(__FILE__) + "/../test_helper.rb"

describe "04ViewGroupDetails" do
  include TestHelper
  
  let(:groups_page) { GroupsPage.new(driver) }
  let(:groups_details_page) { GroupsDetailsPage.new(driver) }

  before(:all) do
    # browser_type, browser_options, site_url are defined in test_helper.rb
    @driver = $driver = Selenium::WebDriver.for(browser_type, browser_options)
    driver.manage().window().resize_to(1280, 800)
    driver.get(site_url)
  end

  before(:each) do
    groups_page = GroupsPage.new(driver)
    groups_details_page = GroupsDetailsPage.new(driver)
    groups_page.click_first_group_card unless groups_details_page.group_details_dialog_opened?
  end

  after(:all) do
    driver.quit unless debugging?
  end
  
  def self.general_device_tests(screen_type)
    context "on a #{screen_type} screen size" do

      before(:all) do
        set_window_size_based_on_viewport_size(driver, screen_type)
      end
      
      it "should show the same group title as that shown on the card" do
        groups_details_page.click_close_button unless groups_details_page.group_details_dialog_closed?
        
        group_card = groups_page.get_last_group_card
        card_title_text = groups_page.group_title_text(group_card)

        groups_page.click_card(group_card)

        expect(groups_details_page.get_group_title.text).to eq(card_title_text)
      end

      it "should show the same group description as that shown on the card" do
        groups_details_page.click_close_button unless groups_details_page.group_details_dialog_closed?
        
        group_card = groups_page.get_last_group_card
        card_description_text = groups_page.group_description_text(group_card)

        groups_page.click_card(group_card)

        expect(groups_details_page.get_group_description.text).to eq(card_description_text)
      end

      it "should show the time since the created date for the group" do
        group_created_date = groups_details_page.get_group_created

        group_created_date_content_text = groups_details_page.get_detail_content_text(group_created_date)

        expect(group_created_date_content_text).to match(groups_details_page.time_since_text_pattern)
      end

      it "should show the time since the last activity for the group" do
        group_last_activity_detail = groups_details_page.get_group_last_activity

        group_last_activity_content_text = groups_details_page.get_detail_content_text(group_last_activity_detail)

        expect(group_last_activity_content_text).to match(groups_details_page.time_since_text_pattern)
      end

      it "should show the same member count as that shown on the card" do
        groups_details_page.click_close_button unless groups_details_page.group_details_dialog_closed?
        
        group_card = groups_page.get_first_group_card
        card_member_count_text = groups_page.group_member_count_text(group_card)

        groups_page.click_card(group_card)

        group_member_count_detail = groups_details_page.get_group_members_count

        group_member_count_detail_text = groups_details_page.get_detail_content_text(group_member_count_detail)

        expect(card_member_count_text).to include(group_member_count_detail_text)
      end

      it "should allow the details view to be closed by clicking the 'CLOSE' button" do
        expect(groups_details_page.wait_until_group_details_dialog_opened?).to be true

        groups_details_page.click_close_button

        expect(groups_details_page.wait_until_group_details_dialog_closed?).to be true
      end
    end
  end
  
  general_device_tests(:desktop)
  general_device_tests(:tablet)
  general_device_tests(:handset)
end
