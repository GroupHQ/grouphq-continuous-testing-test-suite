require File.join(File.dirname(__FILE__), "abstract_page.rb")

class GroupInputNamePage < AbstractPage
  def initialize(driver)
    super(driver, "") # <= TEXT UNIQUE TO THIS PAGE
    @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  end
  
  DIALOG_CONTENT = {
    title: "What's your name?",
    input_name_help_text: "Enter a name",
    input_name_required_error_text: "Name is required"  
  }.freeze
  

  DATA_TEST_ELEMENTS = {
    group_input_name_dialog: "group-input-name-dialog",
    group_title: "group-title",
    member_name_form_field: "member-name-form-field",
    member_name_label: "member-name-label",
    member_name_input: "member-name-input",
    member_name_required_error: "member-name-required-error",
    close_button: "close-dialog-button",
    join_button: "join-group-button",
  }.freeze
  
  def dialog_content
    DIALOG_CONTENT
  end  

  def get_group_input_name_dialog
    group_input_dialog = get_element(:group_input_name_dialog)
    
    wait_until_animation_completes(group_input_dialog)
    
    group_input_dialog
  end
  
  def group_input_dialog_opened?
    get_elements(:group_input_name_dialog).one?
  end
  
  def group_input_dialog_closed?
    get_elements(:group_input_name_dialog).empty?
  end    
  
  def wait_until_group_input_dialog_opened?
    @wait.until { get_elements(:group_input_name_dialog).one? }
  end
  
  def wait_until_group_input_dialog_closed?
    @wait.until { get_elements(:group_input_name_dialog).empty? }
  end

  def get_group_title
    get_element(:group_title, get_group_input_name_dialog)
  end

  def get_member_name_form_field
    get_element(:member_name_form_field, get_group_input_name_dialog)
  end

  def get_member_name_label
    get_element(:member_name_label, get_group_input_name_dialog)
  end

  def get_member_name_input(focused = false)
    element = get_element(:member_name_input, get_group_input_name_dialog)
    
    if (focused)
      @wait.until { element.attribute("data-test") == @driver.switch_to.active_element.attribute("data-test") }
    end
    
    element
  end

  def get_member_name_required_error
    get_element(:member_name_required_error, get_group_input_name_dialog)
  end
  
  def form_error_state?
    begin
      get_element(:member_name_required_error, get_group_input_name_dialog)
    rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::StaleElementReferenceError
      return false
    end
    
    true  
  end  

  def get_close_button
    get_element(:close_button, get_group_input_name_dialog)
  end

  def get_join_button
    get_element(:join_button, get_group_input_name_dialog)
  end

  def close_dialog
    get_close_button.click
  end

  def input_name(name)
    get_member_name_input.send_keys(name)
  end

  def click_join_button
    group_details_dialog = GroupsDetailsPage.new(@driver)
    
    member_list_length_before_joining = group_details_dialog.get_group_member_rows.length
    
    join_button = get_join_button
    raise "Join button not displayed" unless join_button.displayed?
    raise "Join button is disabled" unless join_button.enabled?

    join_button.click

    unless form_error_state?
      @wait.until {
        group_input_dialog_closed? && 
        group_details_dialog.get_group_member_rows.length == member_list_length_before_joining + 1
      }
    end
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
