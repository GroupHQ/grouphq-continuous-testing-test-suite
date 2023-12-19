load File.dirname(__FILE__) + "/../test_helper.rb"

describe "View Groups" do
  include TestHelper

  let(:groups_page) { GroupsPage.new(driver) }

  before(:all) do
    # browser_type, browser_options, site_url are defined in test_helper.rb
    @driver = $driver = Selenium::WebDriver.for(browser_type, browser_options)
    driver.manage().window().resize_to(1280, 800)
    driver.get(site_url)
  end

  after(:all) do
    driver.quit unless debugging?
  end

  def self.general_device_tests(screen_type)
    context "on a #{screen_type} screen size" do
      before(:all) do
        set_window_size_based_on_viewport_size(driver, screen_type)
      end

      it "Shows at least three groups" do
        groups = groups_page.get_groups
        expect(groups.length).to be >= 3
      end

      it "Should show a title for each group" do
        groups = groups_page.get_groups

        expect(groups).to_not be_empty

        groups.each do |group|
          title_text = groups_page.group_title_text(group)
          expect(title_text.length).to be > 0
        end
      end

      it "Should show group membership count in 'number / number' format" do
        groups = groups_page.get_groups

        expect(groups).not_to be_empty

        groups.each do |group|
          count_text = groups_page.group_member_count_text(group)
          expect(count_text).to match(/\d+ \/ \d+/), "Group #{group} does not have a valid count format"
        end
      end

      it "Should have current group size less than or equal to total group size" do
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
        groups = groups_page.get_groups

        expect(groups).not_to be_empty

        groups.each do |group|
          description_text = groups_page.group_description_text(group)
          expect(description_text.length).to be > 0
        end
      end

      it "Should show the current sorting of the groups" do
        default_selected_option = groups_page.sort_selection
        sort_options = groups_page.sort_options

        expect(sort_options).to include(default_selected_option.text)
      end

      it "Should have at least two sort options" do
        expect(groups_page.sort_options.length).to be >= 2
      end

      it "Should remove the sort dropdown after an option is selected" do
        sort_options = groups_page.sort_options
        raise "There should be at least one sort option" if sort_options.length == 0

        groups_page.wait_until_groups_load
        groups_page.sort_groups_by(sort_options[0])

        wait = Selenium::WebDriver::Wait.new(:timeout => 3)
        wait.until { groups_page.sort_options_visible? == false }
      end

      it "Should sort the groups from oldest to newest" do
        groups_page.wait_until_groups_load

        groups_page.sort_groups_by("Oldest")

        groups_sorted_by_oldest = groups_page.get_groups

        groups_page.sort_groups_by("Newest")

        groups_sorted_by_newest = groups_page.get_groups

        expect(groups_sorted_by_oldest).to eq(groups_sorted_by_newest.reverse)
      end
    end
  end

  general_device_tests(:desktop)
  general_device_tests(:tablet)
  general_device_tests(:handset)
end
