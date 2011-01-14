When /^I fetch the rss feed for "([^"]*)"$/ do |filter|
  visit(filter + "/rss")
end

Then /^I should see (\d+) instance(?:s)? of "([^"]*)"$/ do |num, selector|
  page.has_css?(selector, :count => num.to_i)
end


