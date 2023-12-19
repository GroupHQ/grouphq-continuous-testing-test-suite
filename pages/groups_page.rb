require File.join(File.dirname(__FILE__), "abstract_page.rb")

class GroupsPage < AbstractPage
  def initialize(driver)
    super(driver, "") # <= TEXT UNIQUE TO THIS PAGE
    @wait = Selenium::WebDriver::Wait.new(:timeout => 5)
  end

  # page functions here ...

  def get_groups
    @wait.until { driver.find_element(:xpath, "//*[@data-test='group-card']") }
    driver.find_elements(:xpath, "//*[@data-test='group-card']")
  end

  def group_member_count_text(group)
    driver.find_element(:css, "[data-test='member-count'").text
  end

  def group_title_text(group)
    group.find_element(:css, "[data-test='title']").text
  end

  def group_description_text(group)
    group.find_element(:css, "[data-test='description']").text
  end

  def sort_selection
    driver.find_element(:css, "[data-test='group-utility-bar-select']")
  end

  def sort_options
    ["Newest", "Oldest", "Most members", "Least members"]
  end

  def sort_options_visible?
    !driver.find_elements(:css, "[data-test='group-utility-bar-select-option']").empty?
  end

  def wait_until_groups_load
    wait = Selenium::WebDriver::Wait.new(:timeout => 3)
    wait.until { driver.find_element(:xpath, "//*[@data-test='group-card']") }
  end

  def sort_groups_by(sort_option)
    normalized_option = sort_option.to_s
    puts normalized_option
    unless sort_options.include?(normalized_option)
      valid_options = sort_options.join(", ")
      raise "Invalid option: '#{normalized_option}'. Valid options are: #{valid_options}."
    end

    sort_box = driver.find_element(:css, "[data-test='group-utility-bar-select']")
    sort_box.click()
    option_boxes = driver.find_elements(:css, "[data-test='group-utility-bar-select-option']")
    option_box = option_boxes.find do |option|
      option.text == normalized_option
    end

    option_box.click
  end
  
  def click_nav_menu
    driver.find_element(:css, "[aria-label='Toggle menu']").click
  end  

  def click_tab(tab_name, screen_type)
    if (screen_type == :tablet || screen_type == :handset)
      menu_tab_identifier = menu_tab_identifiers(tab_name)
      click_nav_menu
      @wait.until { driver.find_element(:css, menu_tab_identifier).displayed? }
      driver.find_element(:css, menu_tab_identifier).click
    else
      tab_identifier = tab_identifiers(tab_name)
      driver.find_element(:css, tab_identifier).click
    end
  end
  
  def tab_identifiers(tab_name)
    case tab_name.downcase
    when "groups"
      "[data-test='groups-tab-default']"
    when "about"
      "[data-test='about-tab-default']"
    when "sources"
      "[data-test='sources-tab-default']"
    else
      raise "Tab name '#{tab_name}' is not available"
    end
  end

  def menu_tab_identifiers(tab_name)
    case tab_name.downcase
    when "groups"
      "[data-test='groups-tab-compact']"
    when "about"
      "[data-test='about-tab-compact']"
    when "sources"
      "[data-test='sources-tab-compact']"
    else
      raise "Tab name '#{tab_name}' is not available"
    end
  end
  
  def click_logo(screen_type)
    data_test_id = screen_type == :tablet || screen_type == :handset ? "site-title-compact" : "site-title-default"
    #@wait.until { driver.find_element(:css, "[data-test='#{data_test_id}']").displayed? }
    driver.find_element(:css, "[data-test='#{data_test_id}']").click
  end

  def is_nav_menu_displayed?
    @wait.until { driver.find_elements(:css, "[data-test='dropdown-tab-list']").any? }
  end
  
  def is_nav_menu_hidden?
    @wait.until { driver.find_elements(:css, "[data-test='dropdown-tab-list']").empty? }
  end  
end


