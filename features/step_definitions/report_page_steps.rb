require 'faster_csv'

Then /^I should see the following table:$/ do |expected_report_front_pages_table|
  expected_report_front_pages_table.diff!(tableish('table tr', 'td,th'))
end

Then /^I should see the main navigation columns$/ do
  And %{I should see "Core" within "#report_navigation"}
  And %{I should see "Handset" within "#report_navigation"}
  And %{I should see "Netbook" within "#report_navigation"}
  And %{I should see "IVI" within "#report_navigation"}
end

When /^I should see the sign in link without ability to add report$/ do
  And %{I should see "Sign In"}
  And %{I should not see "Add report"}
end

When /I view the group report "([^"]*)"$/ do |report_string|
  version, target, test_type, hardware = report_string.downcase.split('/')
  visit("/#{version}/#{target}/#{test_type}/#{hardware}")
end

Then /I should see the imported data from "([^"]*)" and "([^"]*)" in the exported CSV.$/ do |file1, file2|
  input = FasterCSV.read('features/resources/' + file1).drop(1) +
          FasterCSV.read('features/resources/' + file2).drop(1)
  result = FasterCSV.parse(page.body, {:col_sep => ';'}).drop(1)
  result.count.should == input.count

  mapped_result = result.map{ |item| [item[6], item[7], item[11], item[8], item[9], item[10]] }
  (input - mapped_result).should be_empty


end

Then /I should see the imported test cases from "([^"]*)" in the exported CSV.$/ do |file|
  input = FasterCSV.read('features/resources/' + file).drop(1)
  result = FasterCSV.parse(page.body, {:col_sep => ','}).drop(1)
  result.count.should == input.count
  mapped_result = result.map{ |item| [item[0], item[1], item[2], item[3], item[4], item[5]] }
  (input - mapped_result).should be_empty
end

When /I view the report "([^"]*)"$/ do |report_string|
  version, target, test_type, hardware = report_string.downcase.split('/')
  report = MeegoTestSession.first(:conditions =>
   {"version_labels.normalized" => version, :target => target, :hardware => hardware, :testtype => test_type}, :include => :version_label
  )
  raise "report not found with parameters #{version}/#{target}/#{hardware}/#{test_type}!" unless report
  visit("/#{version}/#{target}/#{test_type}/#{hardware}/#{report.id}")
end

Given /^I have created the "([^"]*)" report(?: using "([^"]*)")?$/ do |report_name, report_template|

  Given %{I have created the "#{report_name}" report with date "2010-02-02" using "#{report_template}"}
end

Given /^I have created the "([^"]*)" report with date "([^"]*)"(?: using "([^"]*)")?$/ do |report_name, report_date, report_template|
#Given /^I have created the "([^"]*)" report$/ do |report_name|

  version, target, test_type, hardware = report_name.split('/')

  if not report_template.present?
    report_template = "sample.csv"
  end

  Given "I am on the front page"
  When %{I follow "Add report"}
  And %{I fill in "report_test_execution_date" with "#{report_date}"}
  And %{I choose "#{version}"}
  And %{I select target "#{target}", test set "#{test_type}" and hardware "#{hardware}"}
  And %{I attach the report "#{report_template}"}
  And %{I submit the form at "upload_report_submit"}
  And %{I submit the form at "upload_report_submit"}
end

Given /^there exists a report for "([^"]*)"$/ do |report_name|
  version, target, test_type, hardware = report_name.split('/')

  fpath    = File.join(Rails.root, "features", "resources", "sample.csv")
  testfile = DragnDropUploadedFile.new(fpath)

  user = User.create!(:name => "John Longbottom",
    :email => "email@email.com",
    :password => "password",
    :password_confirmation => "password")

  session = MeegoTestSession.new(:target => target, :hardware => hardware,
    :testtype => test_type, :uploaded_files => [testfile],
    :tested_at => Time.now, :author => user, :editor => user, :release_version => version
  )
  session.generate_defaults! # Is this necessary, or could we just say create! above?
  session.save!
end


When /^I click to edit the report$/ do
  When "I follow \"edit-button\" within \"#edit_report\""
end

When /^I click to print the report$/ do
  When "I follow \"print-button\" within \"#edit_report\""
end

When /^I click to delete the report$/ do
  When "I follow \"delete-button\" within \"#edit_report\""
end

When /^(?:|I )click the element "([^"]*)" for the test case "([^"]*)"$/ do |element, test_case|
  find(:xpath, "//tr[contains(.,'#{test_case}')]").find(element).click
end

When /^(?:|I )submit the comment for the test case "([^"]*)"$/ do |test_case|
  When "I click the element \".small_btn\" for the test case \"#{test_case}\""
end

When /^(?:|I )attach the file "([^"]*)" to test case "([^"]*)"$/ do |file, test_case|
  within(:xpath, "//tr[contains(.,'#{test_case}')]") do
    And "attach the file \"#{Dir.getwd}/features/resources/#{file}\" to \"testcase_attachment\""
  end

  And "I submit the comment for the test case \"#{test_case}\""
end

When /^I remove the attachment from the test case "([^"]*)"$/ do |test_case|
  And "I click the element \"#delete_attachment\" for the test case \"#{test_case}\""
  And "I submit the comment for the test case \"#{test_case}\""
end

When /^I attach the report "([^"]*)"$/ do |file|
  And "attach the file \"#{Dir.getwd}/features/resources/#{file}\" to \"meego_test_session[uploaded_files][]\""
end

Given /^I select target "([^"]*)", test set "([^"]*)" and hardware "([^"]*)"(?: with date "([^\"]*)")?/ do |target, test_type, hardware, date|
  When %{I fill in "report_test_execution_date" with "#{date}"} if date
  When %{I choose "#{target}"}
  And %{I select test set "#{test_type}" and hardware "#{hardware}"}
end

Given /^I select test set "([^"]*)" and hardware "([^"]*)"(?: with date "([^\"]*)")?$/ do |test_type, hardware, date|
  When %{I fill in "report_test_execution_date" with "#{date}"} if date
  When %{I fill in "meego_test_session[testtype]" with "#{test_type}"}
  When %{I fill in "meego_test_session[hardware]" with "#{hardware}"}
end

Then /^I should see the header$/ do
  Then "I should see \"QA Reports\" within \"#header\""
end

Then /^I should not see the header$/ do
  Then "I should not see \"#header\""
end
