Given /^I am an user with a REST authentication token$/ do
  Given %{I have one user "John Restless" with email "resting@man.net" and password "secretpass" and token "foobar"}
end

Given /^I have sent a request with optional parameter "([^"]*)" with value "([^"]*)" via the REST API$/ do |opt, val|
  Given %{the client sends a request with optional parameter "#{opt}" with value "#{val}" via the REST API}
  # Needed in order to get different time stamps for current - previous matching
  sleep 1
end

Given /^there are (\d+) reports from "([^"]*)" under "([^"]*)"$/ do |num, date, report_path|
  release, profile, testset, product = report_path.split '/'
  year, month = date.split '/'

  num.to_i.times do
    s = MeegoTestSession.new(dummy_report)
    s.tested_at = DateTime.new(year, month, i % 28)
    s.version_label_id = VersionLabel.find_by_normalized(release).id
    s.profile = profile
    s.testset = testset
    s.product = product
    s.save!
  end
end

When /^I view the report category "([^"]*)"$/ do |report_path|
  visit report_path
end

Then /^reports from "([^"]*)" should be in the report list under "([^"]*)" do |date, month_name|
  year, month = date.split '/'
  next_month = (month.to_i + 1).to_s

  sessions_in_month = MeegoTestSession.where("tested_at >= '#{year}-#{month}-1' AND tested_at < '#{year}-#{next_month}-1'").count
  find(:xpath, "//table[contains(.,'#{month}')]").all('tr').count.should == sessions_in_month + 1
end

Then /^reports for "([^"]*)" should not be visible on the page$/ do |month_name|
  Then %{I should not see "#{month_name}" within '.index_month'}
end