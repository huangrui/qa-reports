Given /^there are (\d+) reports from "([^"]*)" under "([^"]*)"$/ do |num, date, report_path|
  release, profile, testset, product = report_path.split '/'
  year, month = date.split '/'

  user = User.first ||
    User.new(:name => "Dummy",
             :email => "dummy@dummy.com",
             :password => "dummypw",
             :password_confirmation => "dummypw",
             :authentication_token => "dummytoken")
  user.save! unless user.persisted?

  version_label = VersionLabel.find_by_normalized(release)
  num.to_i.times do |i|
    s = MeegoTestSession.new(@report_template)
    s.tested_at = DateTime.new(year.to_i, month.to_i, i % 27 + 1)
    s.version_label_id = version_label.id
    s.target = profile
    s.testset = testset
    s.product = product
    s.author = user
    s.published = false
    s.save!
  end

  MeegoTestSession.update_all('published = true')
end

When /^I view the report category "([^"]*)"$/ do |report_path|
  visit "/#{report_path}"
end

Then /^reports from "([^"]*)" should be in the report list under "([^"]*)"$/ do |date, month_name|
  year, month = date.split '/'
  next_month = (month.to_i + 1).to_s

  reports_in_month = MeegoTestSession.where("tested_at >= '#{year}-#{month}-1' AND tested_at < '#{year}-#{next_month}-1'").count
  (find(:xpath, "//table[@class='month' and contains(.,'#{month_name}')]").all('tr').count - 1).should == reports_in_month
end

Then /^reports for "([^"]*)" should not be visible on the page$/ do |month_name|
  Then %{I should not see "#{month_name}" within ".index_month"}
end

Then /^I should see a graph containing data for the most recent reports$/ do
  latest_reports = MeegoTestSession.published.order('tested_at DESC, created_at DESC').
    limit(20)

  text_elems = all(:xpath, "id('canvas_wrapper')//div[@class='bluff-text']").map &:text
  graph_dates = text_elems.select {|txt| txt =~ /\d\d\.\d\d/ }.
                map {|txt| txt; txt.split('.').map &:to_i }
  reports_dates = latest_reports.map {|report| [report.tested_at.day, report.tested_at.month]}

  graph_dates.count.should == reports_dates.count
  (graph_dates - reports_dates).should be_empty
end