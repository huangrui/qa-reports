def validate_visible_categories(expected_reports)
  all = MeegoTestSession.all

  expected_testsets = expected_reports.map(&:testset)
  invalid_testsets = all.map(&:testset) - expected_testsets

  expected_products = expected_reports.map(&:product)
  invalid_products = all.map(&:product) - expected_products

  #TODO: Use capybara api
  expected_testsets.each {|ts| Then "I should see \"#{ts}\"" }
  expected_products.each {|p|  Then "I should see \"#{p}\"" }
  invalid_testsets.each {|ts| Then "I should not see \"#{ts}\""}
  invalid_products.each {|p|  Then "I should not see \"#{p}\""}
end

Then %r/^only recent categories from release "([^"]*)" should be shown$/ do |release|
  expected_reports = MeegoTestSession.release(release).where("tested_at > ?", [30.days.ago])
  validate_visible_categories(expected_reports)
end

Then %r/^all categories from release "([^"]*)" should be shown$/ do |release|
  expected_reports = MeegoTestSession.release(release)
  validate_visible_categories(expected_reports)
end
