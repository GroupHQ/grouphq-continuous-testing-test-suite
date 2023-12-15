load File.dirname(__FILE__) + "/../test_helper.rb"

describe "View Groups" do
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

  it "Shows at least three groups" do
    groups_page = GroupsPage.new(driver)
    groups = groups_page.get_groups
    expect(groups.length).to be >= 3
  end

  it "Should show a title for each group" do
    groups_page = GroupsPage.new(driver)
    groups = groups_page.get_groups

    expect(groups).to_not be_empty

    groups.each do |group|
      title_text = groups_page.group_title_text(group)
      expect(title_text.length).to be > 0
    end
  end

  it "Should show group membership count in 'number / number' format" do
    groups_page = GroupsPage.new(driver)
    groups = groups_page.get_groups

    expect(groups).not_to be_empty

    groups.each do |group|
      count_text = groups_page.group_member_count_text(group)
      expect(count_text).to match(/\d+ \/ \d+/), "Group #{group} does not have a valid count format"
    end
  end

  it "Should have current group size less than or equal to total group size" do
    groups_page = GroupsPage.new(driver)
    groups = groups_page.get_groups

    expect(groups).not_to be_empty

    groups.each do |group|
      count_text = groups_page.group_member_count_text(group)
      match = count_text.match(/\b(\d+) \/ (\d+)\b/)
      expect(match).not_to be_nil, "Group #{group} does not have a valid count format"

      current_count = match[1].to_i
      total_count = match[2].to_i

      expect(current_count).to be <= total_count
    end
  end

  it "Should show a preview of the group's description" do
    groups_page = GroupsPage.new(driver)
    groups = groups_page.get_groups

    expect(groups).not_to be_empty

    groups.each do |group|
      description_text = groups_page.group_description_text(group)
      expect(description_text.length).to be > 0
    end
  end
end
