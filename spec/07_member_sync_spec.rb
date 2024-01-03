load File.dirname(__FILE__) + "/../test_helper.rb"

describe "07MemberSync" do
  include TestHelper

  let(:groups_page_user_a) { GroupsPage.new(@driver_user_a) }
  let(:groups_details_page_user_a) { GroupsDetailsPage.new(@driver_user_a) }
  let(:group_input_name_page_user_a) { GroupInputNamePage.new(@driver_user_a) }

  let(:groups_page_user_b) { GroupsPage.new(@driver_user_b) }
  let(:groups_details_page_user_b) { GroupsDetailsPage.new(@driver_user_b) }
  let(:group_input_name_page_user_b) { GroupInputNamePage.new(@driver_user_b) }

  let(:user_a_name) { "Mojo" }
  let(:user_b_name) { "Flint" }

  def join_group(driver, username)
    groups_page = GroupsPage.new(driver)
    groups_details_page = GroupsDetailsPage.new(driver)
    group_input_name_page = GroupInputNamePage.new(driver)

    groups_page.click_last_group_card unless groups_details_page.group_details_dialog_opened?
    groups_details_page.click_join_button
    group_input_name_page.input_name(username)
    group_input_name_page.click_join_button unless groups_details_page.user_in_group?
  end

  def leave_group(driver)
    groups_page = GroupsPage.new(driver)
    groups_details_page = GroupsDetailsPage.new(driver)

    groups_page.click_last_group_card unless groups_details_page.group_details_dialog_opened?
    groups_details_page.click_leave_button if groups_details_page.user_in_group?
  end

  def self.general_device_tests(screen_type)
    context "on a #{screen_type} screen size" do
      describe "two users in a group" do
        describe "joining group effects" do
          before(:all) do
            @driver_user_a = Selenium::WebDriver.for(browser_type, browser_options)
            set_window_size_based_on_viewport_size(@driver_user_a, screen_type)
            @driver_user_a.get(site_url)

            join_group(@driver_user_a, "Mojo")
          end

          before(:each) do
            @driver_user_b = Selenium::WebDriver.for(browser_type, browser_options)
            set_window_size_based_on_viewport_size(@driver_user_b, screen_type)
            @driver_user_b.get(site_url)
          end

          after(:each) do
            leave_group(@driver_user_b)
            @driver_user_b.quit unless debugging?
          end

          after(:all) do
            leave_group(@driver_user_a)
            @driver_user_a.quit unless debugging?
          end

          it "should show the correct snackbar notification to a group member when a new member joins their group" do
            join_group(@driver_user_b, user_b_name)
            expected_snackbar_text = "#{user_b_name} joined the group"
            snackbar_visible = groups_page_user_a.assert_snackbar_text(expected_snackbar_text)

            expect(snackbar_visible).to be_truthy
          end

          it "should show the added member in the member list" do
            join_group(@driver_user_b, user_b_name)
            members = groups_details_page_user_a.get_group_member_rows
            member_names = members.map { |member_row| groups_details_page_user_a.get_member_name(member_row).text }

            expect(member_names).to include(user_b_name)
          end

          it "should show the added member with the correct join date" do
            join_group(@driver_user_b, user_b_name)

            members = groups_details_page_user_a.get_group_member_rows
            member_join_dates = members.map { |member_row| groups_details_page_user_a.get_member_joined_date(member_row).text }

            member_join_dates = member_join_dates.map { |join_date_text| join_date_text.sub(/Joined/, "").strip }

            expect(member_join_dates).to all(match(groups_details_page_user_a.time_since_text_pattern))
          end

          it "should increment the member rows by one" do
            member_rows_before_joining = groups_details_page_user_a.get_group_member_rows.length

            join_group(@driver_user_b, user_b_name)

            expect(groups_details_page_user_a.get_group_member_rows.length).to eq(member_rows_before_joining + 1)
          end

          it "should increment the group's member count on the group details dialog" do
            member_count_before_joining = groups_details_page_user_a.get_current_member_count

            join_group(@driver_user_b, user_b_name)

            member_count_after_joining = groups_details_page_user_a.get_current_member_count

            expect(member_count_after_joining).to eq(member_count_before_joining + 1)
          end

          it "should increment the group's member count on the group card" do
            group_card = groups_page_user_a.get_last_group_card # warning: no same-guarantee
            member_count_before_joining = groups_page_user_a.get_current_member_count(group_card)

            join_group(@driver_user_b, user_b_name)

            group_card = groups_page_user_a.get_last_group_card # warning: no same-guarantee
            member_count_after_joining = groups_page_user_a.get_current_member_count(group_card)

            expect(member_count_after_joining).to eq(member_count_before_joining + 1)
          end

          it "should keep the group details dialog open after a member joins the group" do
            join_group(@driver_user_b, user_b_name)

            expect(groups_details_page_user_a.group_details_dialog_opened?).to be_truthy
          end
        end

        describe "leaving group effects" do
          before(:all) do
            @driver_user_a = Selenium::WebDriver.for(browser_type, browser_options)
            set_window_size_based_on_viewport_size(@driver_user_a, screen_type)
            @driver_user_a.get(site_url)

            join_group(@driver_user_a, "Mojo")
          end

          before(:each) do
            @driver_user_b = Selenium::WebDriver.for(browser_type, browser_options)
            set_window_size_based_on_viewport_size(@driver_user_b, screen_type)
            @driver_user_b.get(site_url)

            join_group(@driver_user_b, user_b_name)
          end

          after(:each) do
            @driver_user_b.quit unless debugging?
          end

          after(:all) do
            leave_group(@driver_user_a)
            @driver_user_a.quit unless debugging?
          end

          it "should show the correct snackbar notification to a group member when another member leaves their group" do
            leave_group(@driver_user_b)
            expected_snackbar_text = "#{user_b_name} left the group"
            snackbar_visible = groups_page_user_a.assert_snackbar_text(expected_snackbar_text)

            expect(snackbar_visible).to be_truthy
          end

          it "should remove the user's member from the member list" do
            leave_group(@driver_user_b)
            members = groups_details_page_user_a.get_group_member_rows
            member_names = members.map { |member_row| groups_details_page_user_a.get_member_name(member_row).text }

            expect(member_names).not_to include(user_b_name)
          end

          it "should decrement the group's member count on the group details dialog" do
            member_count_before_leaving = groups_details_page_user_a.get_current_member_count

            leave_group(@driver_user_b)

            member_count_after_leaving = groups_details_page_user_a.get_current_member_count

            expect(member_count_after_leaving).to eq(member_count_before_leaving - 1)
          end

          it "should decrement the group's member count on the group card" do
            group_card = groups_page_user_a.get_last_group_card # warning: no same-guarantee
            member_count_before_leaving = groups_page_user_a.get_current_member_count(group_card)

            leave_group(@driver_user_b)

            group_card = groups_page_user_a.get_last_group_card # warning: no same-guarantee
            member_count_after_leaving = groups_page_user_a.get_current_member_count(group_card)

            expect(member_count_after_leaving).to eq(member_count_before_leaving - 1)
          end

          it "should keep the group details dialog open after a member leaves the group" do
            leave_group(@driver_user_b)

            expect(groups_details_page_user_a.group_details_dialog_opened?).to be_truthy
          end
        end
      end
    end
  end
  
  general_device_tests(:desktop)
  general_device_tests(:tablet)
  general_device_tests(:handset)
end
