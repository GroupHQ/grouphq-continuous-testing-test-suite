load File.dirname(__FILE__) + "/../test_helper.rb"

describe "05JoinGroup" do
  include TestHelper

  def self.general_device_tests(screen_type)
    context "on a #{screen_type} screen size" do
      describe "group input name dialog" do
        let(:groups_page) { GroupsPage.new(driver) }
        let(:groups_details_page) { GroupsDetailsPage.new(driver) }
        let(:group_input_name_page) { GroupInputNamePage.new(driver) }

        before(:all) do
          @driver = $driver = Selenium::WebDriver.for(browser_type, browser_options)
          set_window_size_based_on_viewport_size(driver, screen_type)
          driver.get(site_url)
        end

        before(:each) do
          group_input_name_page.close_dialog unless group_input_name_page.group_input_dialog_closed?
          groups_details_page.click_close_button unless groups_details_page.group_details_dialog_closed?
          groups_page.click_last_group_card
          groups_details_page.click_join_button
        end

        after(:all) do
          driver.quit unless debugging?
        end

        it "should open the dialog when trying to join the group from the group details dialog" do
          expect(group_input_name_page.group_input_dialog_opened?).to be_truthy
        end

        it "should close the dialog when clicking the 'CLOSE' button" do
          group_input_name_page.close_dialog
          expect(group_input_name_page.wait_until_group_input_dialog_closed?).to be_truthy
        end

        describe "dialog details" do
          it "should show the dialog title" do
            title = group_input_name_page.dialog_content[:title]
            expect(group_input_name_page.get_group_title.text).to eq(title)
          end

          it "should show the input name field" do
            expect(group_input_name_page.get_member_name_input).to be_truthy
          end

          it "should show the help text in the input name field" do
            help_text = group_input_name_page.dialog_content[:input_name_help_text]
            expect(group_input_name_page.get_member_name_label.text).to eq(help_text)
          end
        end

        describe "dialog errors" do
          it "should show the required warning when a user unfocuses the input field without a name" do
            input_name_field = group_input_name_page.get_member_name_input(true)
            focused_element = @driver.switch_to.active_element

            expect(input_name_field.attribute("data-test")).to eq(focused_element.attribute("data-test"))
          end

          it "should disable the button when submitting a name containing empty spaces" do
            input_name_field = group_input_name_page.get_member_name_input
            input_name_field.send_keys("   ")

            group_input_name_page.click_join_button
            join_button = group_input_name_page.get_join_button

            expect(join_button.enabled?).to be_falsey
          end

          it "should show the name required warning when submitting a name containing empty spaces" do
            input_name_field = group_input_name_page.get_member_name_input
            input_name_field.send_keys("   ")

            group_input_name_page.click_join_button
            member_name_required_error = group_input_name_page.get_member_name_required_error
            expected_error_text = group_input_name_page.dialog_content[:input_name_required_error_text]

            expect(member_name_required_error.text).to eq(expected_error_text)
          end
        end
      end

      describe "joining group" do
        let(:groups_page) { GroupsPage.new(driver) }
        let(:groups_details_page) { GroupsDetailsPage.new(driver) }
        let(:group_input_name_page) { GroupInputNamePage.new(driver) }
        let (:my_member_name) { "Klunk" }

        before(:each) do
          @driver = $driver = Selenium::WebDriver.for(browser_type, browser_options)
          set_window_size_based_on_viewport_size(driver, screen_type)
          driver.get(site_url)

          groups_page.click_last_group_card
          groups_details_page.click_join_button
          group_input_name_page.input_name("Klunk")
        end

        after(:each) do
          group_input_name_page.close_dialog unless group_input_name_page.group_input_dialog_closed?
          groups_page.click_last_group_card unless groups_details_page.group_details_dialog_opened?
          groups_details_page.click_leave_button if groups_details_page.user_in_group?

          @driver.quit unless debugging?
        end

        it "should close the group input name dialog after successfully joining a group" do
          group_input_name_page.click_join_button
          expect(group_input_name_page.wait_until_group_input_dialog_closed?).to be_truthy
        end

        it "should show the correct snackbar notification after successfully joining a group" do
          group_input_name_page.click_join_button
          expected_snackbar_text = "Successfully joined group"
          snackbar_visible = groups_page.assert_snackbar_text(expected_snackbar_text)
          expect(snackbar_visible).to be_truthy
        end

        it "should remember the user's group after refreshing the page" do
          group_input_name_page.click_join_button

          expected_snackbar_text = "Successfully joined group"
          snackbar_visible = groups_page.assert_snackbar_text(expected_snackbar_text)
          expect(snackbar_visible).to be_truthy

          @driver.navigate.refresh

          groups_page.click_last_group_card
          expect(groups_details_page.user_in_group?).to be_truthy
        end

        it "should show the added member in the member list" do
          group_input_name_page.click_join_button

          members = groups_details_page.get_group_member_rows
          member_names = members.map { |member_row| groups_details_page.get_member_name(member_row).text }

          expect(member_names).to include(my_member_name)
        end

        it "should show the added member with the correct join date" do
          group_input_name_page.click_join_button

          members = groups_details_page.get_group_member_rows
          member_join_dates = members.map { |member_row| groups_details_page.get_member_joined_date(member_row).text }

          member_join_dates = member_join_dates.map { |join_date_text| join_date_text.sub(/Joined/, "").strip }

          expect(member_join_dates).to all(match(groups_details_page.time_since_text_pattern))
        end

        it "should increment the member rows by one" do
          member_rows_before_joining = groups_details_page.get_group_member_rows.length
          group_input_name_page.click_join_button

          expect(groups_details_page.get_group_member_rows.length).to eq(member_rows_before_joining + 1)
        end

        it "should increment the group's member count on the group details dialog" do
          member_count_before_joining = groups_details_page.get_current_member_count
          group_input_name_page.click_join_button
          member_count_after_joining = groups_details_page.get_current_member_count

          expect(member_count_after_joining).to eq(member_count_before_joining + 1)
        end

        it "should increment the group's member count on the group card" do
          group_card = groups_page.get_last_group_card # warning: no same-guarantee
          member_count_before_joining = groups_page.get_current_member_count(group_card)

          group_input_name_page.click_join_button

          group_card = groups_page.get_last_group_card # warning: no same-guarantee
          member_count_after_joining = groups_page.get_current_member_count(group_card)

          expect(member_count_after_joining).to eq(member_count_before_joining + 1)
        end

        it "should add the 'current group' icon to the group's card" do
          group_input_name_page.click_join_button

          group = groups_page.get_last_group_card

          expect(groups_page.has_current_group_icon?(group)).to be_truthy
        end

        it "should keep the group details dialog open after successfully joining the group" do
          group_input_name_page.click_join_button

          expected_snackbar_text = "Successfully joined group"
          snackbar_visible = groups_page.assert_snackbar_text(expected_snackbar_text)
          expect(snackbar_visible).to be_truthy

          expect(groups_details_page.group_details_dialog_opened?).to be_truthy
        end
      end
    end
  end
  
  general_device_tests(:desktop)
  general_device_tests(:tablet)
  general_device_tests(:handset)
end
