Given /^I upload a new report with different comments$/ do
  report = FactoryGirl.build(:test_report)
  report.features << FactoryGirl.build(:feature, :name => "WLAN")
end

And /^(?:|I )upload the report "([^"]*)" with different comments$/ do |report|
    When %{I follow "Add report"}
    And %{I select target "Core", test set "automated" and product "N900" with date "2010-02-12"}
    And %{I attach the report "#{report}"}
    And %{submit the form at "upload_report_submit"}
end

Then /^the testcase "([^"]*)" should have the new comment$/ do |testcase|
  session = MeegoTestSession.last
  tc = session.meego_test_cases.find_by_name(testcase)
  Then %{I should see "#{tc.comment}" within "#testcase-#{tc.id}"}
end

And /^the testcase "([^"]*)" should have the comment from the previous report$/ do |testcase|
  session = MeegoTestSession.last
  tc = session.meego_test_cases.find_by_name(testcase)
  prev_tc = session.prev_session.meego_test_cases.find_by_name(testcase)
  Then %{I should see "#{prev_tc.comment}" within "#testcase-#{tc.id}"}
end