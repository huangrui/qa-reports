focused_input = ""

def selected_release
  #release_navi = find('#version_navi .current a')
  #release_name = release_navi[:href].split('/').last
  Release.first.name
end

def category_url(*category)
  "/#{selected_release()}/#{category.join('/')}"
end

def category_selector(*category)
  "#report_navigation a.name[href='#{category_url(category)}']"
end

When /^I have uploaded reports with profile "([^"]*)" having testset "([^"]*)" and product "([^"]*)"$/ do |profile, testset, product|
  FactoryGirl.create_list(:test_report, 2,
    :release => Release.find_by_name(selected_release()),
    :target  => profile.downcase,
    :testset => testset,
    :product => product,
    :title => "#{testset} Test Report: #{product} Basic Feature 2011-09-29")
end

When /^I click on the edit button$/ do
  When "I press \"home_edit_link\""
end

When /^I edit the testset name "([^"]*)" to "([^"]*)" for profile "([^"]*)"$/ do |orig_name, new_name, profile|
  testset = find category_selector(profile, orig_name)
  testset.click
  #sleep 4

  url = category_url(profile, orig_name)
  find("#report_navigation input", :visible => true).set new_name
end

When /^I press enter$/ do
  find("#report_navigation input").native.send_key("\n")
end

Then /^I should see testset "([^"]*)" for profile "([^"]*)"$/ do |testset, profile|
  visit('/')
  url = category_url(profile,testset)
  sel = "#report_navigation a.name[href='#{url}']"
  Then %{I should see "#{testset}" within "#{sel}"}
end

When /^I click done$/ do
  click_on("home_edit_done_link")
end

When /^I reload the front page$/ do
  visit('/')
end

When /^I press escape$/ do
  focused_input.native.send_key("\e")
end

When /^I rename the testset "([^"]*)" under profile "([^"]*)" to "([^"]*)"$/ do |orig_name, profile, new_name|
  Then %{I click on the edit button}
  And %{I edit the testset name "#{orig_name}" to "#{new_name}" for profile "#{profile}"}
  And %{I press enter}
  And %{I click done}
end

When /^I view the group report for "([^"]*)"$/ do |path|
  visit("/#{selected_release}/#{path}")
end

Then /^I should see "([^"]*)" in test reports titles$/ do |title|
  Then %{I should see "#{title}" within "#report_filtered_navigation .report_name"}
end

Then /^I should not see "([^"]*)" in test reports titles$/ do |title|
  Then %{I should not see "#{title}" within "#report_filtered_navigation .report_name"}
end

Then /^I should not see the edit button$/ do
  page.should have_no_link("home_edit_link")
end

When /^I edit the product name "([^"]*)" to "([^"]*)"$/ do |old_name, new_name|
  product = first("#report_navigation .products a", :text => old_name)
  product.click
  focused_input = product.find(:xpath, "../input")
  focused_input.set new_name
end

When /^I rename the product "([^"]*)" to "([^"]*)"$/ do |old_name, new_name|
  Then %{I click on the edit button}
  And %{I edit the product name "#{old_name}" to "#{new_name}"}
  And %{I press enter}
  And %{I click done}
end
