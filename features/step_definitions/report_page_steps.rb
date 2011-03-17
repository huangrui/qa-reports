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

When /I view the report "([^"]*)"$/ do |report_string|
  version, target, test_type, hardware = report_string.downcase.split('/')
  report = MeegoTestSession.first(:conditions =>
   {:release_version => VersionLabel.where(:normalized => version.downcase).first().id, :target => target, :hwproduct => hardware, :testtype => test_type}
  )
  raise "report not found with parameters #{version}/#{target}/#{hardware}/#{test_type}!" unless report
  visit("/#{version}/#{target}/#{test_type}/#{hardware}/#{report.id}")
end

Given /^I have created the "([^"]*)" report(?: using "([^"]*)")?(?: at "([^"]*)")?$/ do |report_name, report_template, report_at|
#Given /^I have created the "([^"]*)" report(?: using "([^"]*)")?$/ do |report_name, report_template|
#Given /^I have created the "([^"]*)" report$/ do |report_name|

  version, target, test_type, hardware = report_name.split('/')

  if not report_template
    report_template = "sample.csv"
  end
  
  if not report_at
    report_at = "2010-02-02"
  end

  #if version.eql?"1.2"
  #   version = 1;
  #elsif version.eql? "1.1"
  #   version = 2;
  #else
  #   version = 3;
  #end

  Given "I am on the front page"
  When %{I follow "Add report"}
  And %{I fill in "report_test_execution_date" with "#{report_at}"}
#  And %{I fill in "report_test_execution_date" with "2010-02-02"}
  And %{I choose "#{version}"}
  And %{I select target "#{target}", test type "#{test_type}" and hardware "#{hardware}"}
  And %{I attach the report "#{report_template}"}
  And %{I submit the form at "upload_report_submit"}
  And %{I submit the form at "upload_report_submit"}
end

Given /^there exists a report for "([^"]*)"$/ do |report_name|
  version, target, test_type, hardware = report_name.split('/')

  fpath = File.join(Rails.root, "features", "resources", "sample.csv")

  user = User.create!(:name => "John Longbottom",
    :email => "email@email.com",
    :password => "password",
    :password_confirmation => "password")

  session = MeegoTestSession.new(:target => target, :hwproduct => hardware,
    :testtype => test_type, :uploaded_files => [fpath],
    :tested_at => Time.now, :author => user, :editor => user, :release_version => VersionLabel.where(:normalized => version.downcase).first().id
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

When /^I attach the report "([^"]*)"$/ do |file|
  And "attach the file \"#{Dir.getwd}/features/resources/#{file}\" to \"meego_test_session[uploaded_files][]\""
end

Given /^I select target "([^"]*)", test type "([^"]*)" and hardware "([^"]*)"(?: with date "([^\"]*)")?/ do |target, test_type, hardware, date|
  When %{I fill in "report_test_execution_date" with "#{date}"} if date
  When %{I choose "#{target}"}
  And %{I select test type "#{test_type}" and hardware "#{hardware}"}
end

Given /^I select test type "([^"]*)" and hardware "([^"]*)"(?: with date "([^\"]*)")?$/ do |test_type, hardware, date|
  When %{I fill in "report_test_execution_date" with "#{date}"} if date
  When %{I fill in "meego_test_session[testtype]" with "#{test_type}"}
  When %{I fill in "meego_test_session[hwproduct]" with "#{hardware}"}
end

Then /^I should see the header$/ do
  Then "I should see \"QA Reports\" within \"#header\""
end

Then /^I should not see the header$/ do
  Then "I should not see \"#header\""
end
