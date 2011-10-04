focused_input = ""

Given /^I have no target labels$/ do
  TargetLabel.delete_all
end

When /^I have uploaded reports with profile "([^"]*)" having testset "([^"]*)"$/ do |profile, testset|
#  FactoryGirl.create(:profile, :label => profile, :normalized => profile.downcase) if TargetLabel.find_by_label(profile).nil?
  FactoryGirl.create_list(:test_report, 2,
    :release => Release.in_sort_order.first,
    :target  => profile.downcase,
    :testset => testset)
end

When /^I click on the edit button$/ do
  When "I press \"home_edit_link\""
end

When /^I edit the testset name "([^"]*)" to "([^"]*)" for profile "([^"]*)"$/ do |orig_name, new_name, profile|
  testset_sel       = "#{Release.in_sort_order.first.name}/#{profile}/#{orig_name}".gsub(/\//,'-').gsub(/\s/,'-').gsub(/\./,'_')
  input_testset_sel = "input-#{testset_sel}"

  click_on(testset_sel)
  fill_in input_testset_sel, :with => new_name
  focused_input = find("##{input_testset_sel}")
end

When /^I press enter$/ do
  focused_input.native.send_key("\n")
end

Then /^I should see testset "([^"]*)" for profile "([^"]*)"$/ do |testset, profile|
  puts find('.profiles')

  Then %{I should see "#{testset}" within ".testsets"}
end

When /^I press done button$/ do
  click_on("#home_edit_done_link")
end

When /^I reload the front page$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I press escape button$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I rename the testset "([^"]*)" under profile "([^"]*)" to "([^"]*)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

When /^I view the group report for "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should see "([^"]*)" in test reports titles$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should not see "([^"]*)" in test reports titles$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
