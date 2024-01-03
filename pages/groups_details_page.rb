require File.join(File.dirname(__FILE__), "abstract_page.rb")

class GroupsDetailsPage < AbstractPage
  def initialize(driver)
    super(driver, "") # <= TEXT UNIQUE TO THIS PAGE
    @wait = Selenium::WebDriver::Wait.new(:timeout => 5)
  end

  DATA_TEST_ELEMENTS = {
    group_details_dialog: "group-details-dialog",
    group_title: "group-title",
    group_description: "group-description",
    group_info: "group-info",
    group_extra_info: "group-extra-info",
    group_detail_title: "detail-title",
    group_detail_content: "detail-content",
    group_created_date: "group-creation-time",
    group_last_activity: "group-last-activity",
    group_members_count: "group-members-count",
    group_member_list: "group-member-list",
    group_member: "group-member",
    member_list_subheader: "member-list-subheader",
    member_name: "member-name",
    member_joined_date: "member-joined-date",
    no_members_message: "no-members-message",
    group_actions: "group-actions",
    close_button: "close-group-details-dialog-button",
    action_button: "group-details-action-dialog-button",
  }.freeze

  def get_group_details_dialog
    group_details_dialog = get_element(:group_details_dialog)
    
    wait_until_animation_completes(group_details_dialog)
    
    group_details_dialog
  end
  
  def group_details_dialog_opened?
    get_elements(:group_details_dialog).one?
  end
  
  def group_details_dialog_closed?
    get_elements(:group_details_dialog).empty?
  end    
  
  def wait_until_group_details_dialog_opened?
    @wait.until { get_elements(:group_details_dialog).one? }
  end
  
  def wait_until_group_details_dialog_closed?
    @wait.until { get_elements(:group_details_dialog).empty? }
  end

  def get_group_title
    get_element(:group_title, get_group_details_dialog)
  end
  
  def get_group_info
    get_element(:group_info, get_group_details_dialog)
  end
  
  def get_group_extra_info
    get_element(:group_extra_info, get_group_details_dialog)
  end    

  def get_group_description
    get_element(:group_description, get_group_details_dialog)
  end

  def get_group_created
    get_element(:group_created_date, get_group_details_dialog)
  end

  def get_group_last_activity
    get_element(:group_last_activity, get_group_details_dialog)
  end

  def get_group_members_count
    get_element(:group_members_count, get_group_details_dialog)
  end
  
  def get_current_member_count
    member_count_numbers = get_group_members_count.text.match(member_count_text_pattern)
    
    raise "Invalid member count: #{member_count_text_before}" if member_count_numbers.nil?
    
    member_count_numbers[0].to_i
  end

  def get_group_member_list
    get_element(:group_member_list, get_group_details_dialog)
  end
  
  def get_group_member_rows
    get_elements(:group_member, get_group_member_list)
  end  
  
  def get_detail_header_text(detail_element)
    get_element(:group_detail_title, detail_element).text
  end

  def get_detail_content_text(detail_element)
    get_element(:group_detail_content, detail_element).text
  end

  def get_member_list_subheader
    get_element(:member_list_subheader, get_group_details_dialog)
  end

  def get_member_name(member_row)
    get_element(:member_name, member_row)
  end

  def get_member_joined_date(member_row)
    get_element(:member_joined_date, member_row)
  end

  def get_no_members_message
    get_element(:no_members_message, get_group_details_dialog)
  end

  def get_close_button
    get_element(:close_button, get_group_details_dialog)
  end

  def get_action_button
    @wait.until { get_element(:action_button, get_group_details_dialog) }
  end

  def click_close_button
    get_close_button.click
  end

  def click_leave_button
    leave_button = get_action_button
    
    member_list_length_before_leaving = get_group_member_rows.length
    
    raise "Button is not in leave state. Current text: #{leave_button.text}" unless user_in_group?
    raise "Leave button not displayed" unless leave_button.displayed?
    raise "Leave button is disabled" unless leave_button.enabled?
    
    leave_button.click
    
    @wait.until {
      get_group_member_rows.length == member_list_length_before_leaving - 1
    }
  end

  def click_join_button
    join_button = get_action_button

    raise "Join button not displayed" unless join_button.displayed?
    raise "User is currently in group" if user_in_group?
    raise "Join button is disabled" unless join_button.enabled?

    join_button.click
  end
  
  def user_in_group?
    get_action_button.text.downcase.include?("leave") 
  end  

  private

  def get_element(test_name, parentElement = nil)
    if (parentElement)
      parentElement.find_element(:css, get_locator(test_name))
    else
      driver.find_element(:css, get_locator(test_name))
    end
  end

  def get_elements(test_name, parentElement = nil)
    if (parentElement)
      parentElement.find_elements(:css, get_locator(test_name))
    else
      driver.find_elements(:css, get_locator(test_name))
    end
  end

  def get_locator(test_name)
    raise "Test name must be a symbol" unless test_name.is_a?(Symbol)

    attribute_value = DATA_TEST_ELEMENTS[test_name]
    "[data-test='#{attribute_value}']"
  end
end
