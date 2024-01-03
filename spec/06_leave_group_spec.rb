load File.dirname(__FILE__) + "/../test_helper.rb"

describe "LeaveGroup" do
  include TestHelper
  
  let(:groups_page) { GroupsPage.new(driver) }
  let(:groups_details_page) { GroupsDetailsPage.new(driver) }
  let(:group_input_name_page) { GroupInputNamePage.new(driver) }

  before(:each) do
    @driver = $driver = Selenium::WebDriver.for(browser_type, browser_options)
    driver.manage().window().resize_to(1280, 800)
    driver.get(site_url)
    
    groups_page.click_last_group_card
    groups_details_page.click_join_button
    group_input_name_page.input_name("Klunk")
    group_input_name_page.click_join_button
  end
  
  after(:each) do
    group_input_name_page.close_dialog unless group_input_name_page.group_input_dialog_closed?
    groups_page.click_last_group_card unless groups_details_page.group_details_dialog_opened?
    groups_details_page.click_leave_button if groups_details_page.user_in_group?
    
    @driver.quit unless debugging?
  end  

  describe "leaving group" do
    let (:my_member_name) { "Klunk" }
    
    it "should show the correct snackbar notification after successfully leaving a group" do
      groups_details_page.click_leave_button
      expected_snackbar_text = "Successfully left group"
      snackbar_visible = groups_page.assert_snackbar_text(expected_snackbar_text)
      
      expect(snackbar_visible).to be_truthy      
    end

    it "should remove the user's member from the member list" do
      groups_details_page.click_leave_button

      members = groups_details_page.get_group_member_rows
      member_names = members.map { |member_row| groups_details_page.get_member_name(member_row).text }

      expect(member_names).not_to include(my_member_name)      
    end
    
    it "should increment the member rows by one" do
      member_rows_before_leaving = groups_details_page.get_group_member_rows.length
      groups_details_page.click_leave_button
      
      expect(groups_details_page.get_group_member_rows.length).to eq(member_rows_before_leaving - 1)      
    end
      
    it "should decrement the group's member count on the group details dialog" do
      member_rows_before_leaving = groups_details_page.get_current_member_count
      groups_details_page.click_leave_button
      member_count_after_leaving = groups_details_page.get_current_member_count
      
      expect(member_count_after_leaving).to eq(member_rows_before_leaving - 1)
    end

    it "should decrement the group's member count on the group card" do
      group_card = groups_page.get_last_group_card # warning: no same-guarantee
      member_count_before_leaving = groups_page.get_current_member_count(group_card)
      
      groups_details_page.click_leave_button
      
      group_card = groups_page.get_last_group_card # warning: no same-guarantee
      member_count_after_leaving = groups_page.get_current_member_count(group_card)

      expect(member_count_after_leaving).to eq(member_count_before_leaving - 1)
    end

    it "should remove the 'current group' icon from the group's card" do
      groups_details_page.click_leave_button
      
      group = groups_page.get_last_group_card # warning: no same-guarantee
      
      expect(groups_page.has_current_group_icon?(group)).to be_falsey
    end

    it "should keep the group details dialog open after successfully leaving the group" do
      groups_details_page.click_leave_button
      
      expect(groups_details_page.group_details_dialog_opened?).to be_truthy
    end
  end
end
