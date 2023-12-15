require File.join(File.dirname(__FILE__), "abstract_page.rb")

class GroupsPage < AbstractPage
  def initialize(driver)
    super(driver, "") # <= TEXT UNIQUE TO THIS PAGE
  end

  # page functions here ...

  def get_groups
    wait = Selenium::WebDriver::Wait.new(:timeout => 3)
    wait.until {
      driver.find_element(:xpath, "//*[@data-test='group-card']")
    }
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
end
