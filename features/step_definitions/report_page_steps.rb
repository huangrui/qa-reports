require 'db_state'

Then /^I should see the following table:$/ do |expected_report_front_pages_table|
  expected_report_front_pages_table.diff!(tableish('table tr', 'td,th'))
end

When /I view the report "([^"]*)"$/ do |report_string|
  target, hardware, test_type = report_string.split('_')
  report = MeegoTestSession.all.detect do |ts|
    ts.attributes.values_at('target', 'hwproduct', 'testtype').map(&:downcase) == [target, hardware, test_type]
  end
  raise "report not found with given parameters!" unless report
  visit("report/view/#{report.id}")
end

Given /^I have created the "([^"]*)" report$/ do |report_name|
  DBState.load(File.join("features/resources/#{report_name}_state.sql"))
end

# Report page actions

When /^I click to edit the report$/ do
  When "I follow \"edit-button\" within \".page_content\""
end

When /^I click to print the report$/ do
  When "I follow \"print-button\" within \".page_content\""
end


When /^I click to delete the report$/ do
  When "I follow \"delete-button\" within \".page_content\""
end

When /^I attach the report "([^"]*)"$/ do |file|
  And "attach the file \"features/resources/#{file}\" to \"meego_test_session[uploaded_files][]\" within \"#browse\""
end



When /^I fill in target "([^"]*)", test type "([^"]*)" and hardware "([^"]*)"$/ do |target, test_type, hardware|
  When "I fill in \"meego_test_session[target]\" with \"#{target}\""
  When "I fill in \"meego_test_session[testtype]\" with \"test_type}\""
  When "I fill in \"meego_test_session[hwproduct]\" with \"#{hardware}\""
end


Then /^I should see the header$/ do
  Then "I should see \"QA Reports\" within \"#header\""
end

Then /^I should not see the header$/ do
  Then "I should not see \"#header\""
end
