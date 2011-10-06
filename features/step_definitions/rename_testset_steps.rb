focused_input = ""
RELEASE = Release.in_sort_order.first
def testset_selector(profile, testset)
  return "#{Release.in_sort_order.first.name}/#{profile}/#{testset}".gsub(/\//,'-').gsub(/\s/,'-').gsub(/\./,'_')
end

Given /^I have no target labels$/ do
  TargetLabel.delete_all
end

When /^I have uploaded reports with profile "([^"]*)" having testset "([^"]*)"$/ do |profile, testset|
#  FactoryGirl.create(:profile, :label => profile, :normalized => profile.downcase) if TargetLabel.find_by_label(profile).nil?
  FactoryGirl.create_list(:test_report, 2,
    :release => Release.in_sort_order.first,
    :target  => profile.downcase,
    :testset => testset,
    :title => "#{testset} Test Report: N900 Basic Feature 2011-09-29")
end

When /^I click on the edit button$/ do
  When "I press \"home_edit_link\""
end

When /^I edit the testset name "([^"]*)" to "([^"]*)" for profile "([^"]*)"$/ do |orig_name, new_name, profile|
  testset_sel       = testset_selector(profile, orig_name)
  input_testset_sel = "input-#{testset_sel}"

  click_on(testset_sel)
  fill_in input_testset_sel, :with => new_name
  focused_input = find("##{input_testset_sel}")
end

When /^I press enter key$/ do
  focused_input.native.send_key("\n")
end

Then /^I should see testset "([^"]*)" for profile "([^"]*)"$/ do |testset, profile|
  sel = testset_selector(profile,testset)
  Then %{I should see "#{testset}" within "#{sel}"}
end

When /^I press done button$/ do
  click_on("#home_edit_done_link")
end

When /^I reload the front page$/ do
  visit('/')
end

When /^I press escape key$/ do
  focused_input.native.send_key("\e")
end

When /^I rename the testset "([^"]*)" under profile "([^"]*)" to "([^"]*)"$/ do |orig_name, profile, new_name|
  Then %{I click on the edit button}
  And %{I edit the testset name "#{orig_name}" to "#{new_name}" for profile "#{profile}"}
  And %{I press enter key}
  And %{I press done button}
end

When /^I view the group report for "([^"]*)"$/ do |path|
  visit("/#{RELEASE.name}/#{path}")
end

Then /^I should see "([^"]*)" in test reports titles$/ do |title|
  Then %{I should see "#{title}" within "#report_filtered_navigation .report_name"}
end

Then /^I should not see "([^"]*)" in test reports titles$/ do |title|
  Then %{I should not see "#{title}" within "#report_filtered_navigation .report_name"}
end
