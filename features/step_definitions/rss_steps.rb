When /^I fetch the rss feed for "([^"]*)"$/ do |filter|
  filter = "/#{filter}" unless (filter.start_with?("/") or filter =~ URI::regexp)
  visit(filter + "/rss")
end

Then /^I should see (\d+) instance(?:s)? of "([^"]*)"$/ do |num, selector|
  assert page.has_css?(selector, :count => num.to_i)
end

Then /^I should see the page header offer RSS feed for "([^"]*)"$/ do |rssfeed|
  rsslink = "/" + rssfeed + "/rss"
  assert page.has_css?("head link[href=\"#{rsslink}\"]")
end

  



