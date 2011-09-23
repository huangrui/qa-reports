Then /^show me the response$/ do
  puts page.body.inspect
end

When /submit the form(?: at "([^"]*)")?$/ do |form_id|
  target = form_id ? "#"+form_id : "input[@type='submit']"
  find(target).click
end

When /submit the form at "([^"]*)" within "([^"]*)"?$/ do |submit_button, selector|
  with_scope(selector) do
    find(submit_button).click
  end
end

When /^(?:|I )wait until all Ajax requests are complete$/ do
  wait_until do
    page.evaluate_script('$.active') == 0
  end
end

When /^I wait for (\d+)s$/ do |n|
  sleep n.to_i
end

Then /^I should really see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, locator| #"
  if Capybara.current_driver == :selenium or Capybara.current_driver == :webkit
    wait_until do
      script = <<-eos
      (function () {
        var containsText = $('#{locator} :contains(#{text}), #{locator}:contains(#{text})');
        var leaves = containsText.not(containsText.parents()).filter(':visible');
        return leaves.filter(function() {return !$(this).parents().is(':hidden');}).length > 0;
      })();
      eos
      page.evaluate_script(script).should be_true
    end
  else
    with_scope(locator) do
      page.should have_content(text)
    end
  end
end

Then /^I really should not see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, locator| #"
  if Capybara.current_driver == :selenium or Capybara.current_driver == :webkit
    wait_until do
      script = <<-eos
      (function () {
        var containsText = $('#{locator} :contains(#{text}), #{locator}:contains(#{text})');
        var leaves = containsText.not(containsText.parents()).filter(':visible');
        return leaves.filter(function() {return !$(this).parents().is(':hidden');}).length > 0;
      })();
      eos
      page.evaluate_script(script).should be_false
    end
  else
    with_scope(locator) do
      page.should have_no_content(text)
    end
  end
end


Then /^the link "([^"]*)" within "([^"]*)" should point to the report "([^"]*)"/ do |link, selector, expected_report|
  with_scope(selector) do
    field = find_link(link)

    version, target, testset, product = expected_report.split('/')
    report = MeegoTestSession.first(:conditions =>
     {"releases.name" => version, "profiles.label" => target, :product => product, :testset => testset}, :include => [:release, :profile]
    )
    raise "report not found with parameters #{version}/#{target}/#{hardware}/#{testset}!" unless report

    field[:href].should == "/#{version}/#{target}/#{testset}/#{product}/#{report.id}"
  end
end

When /^I click the element "([^"]*)"$/ do |selector|
  find(selector).click
end

When /^I scroll down the page$/ do
  page.evaluate_script('window.location.hash="footer";')
  And %{I wait until all Ajax requests are complete}
end

When /^I click the element "([^"]*)" within "([^"]*)"$/ do |element, selector|
  with_scope(selector) do
    find(element).click
  end
end

When /^fill in "([^"]*)" within "([^"]*)" with:$/ do |field, selector, data|
  with_scope(selector) do
    fill_in(field, :with => data)
  end
end

When /^I view the page for the release version "([^"]*)"$/ do |version|
  visit("/#{version}")
end

When /^I view the page for the "([^"]*)" (?:target|profile) of release version "([^"]*)"$/ do |target, version|
  visit("/#{version}/#{target}")
end

When /^I view the page for "([^"]*)" (?:|testing) of (?:target|profile) "([^"]*)" in version "([^"]*)"$/ do |test_type, target, version|
  visit("/#{version}/#{target}/#{test_type}")
end

When /^I view the page for "([^"]*)" (?:|testing )of "([^"]*)" hardware with (?:target|profile) "([^"]*)" in version "([^"]*)"$/ do |test_type, hardware, target, version|
  visit("/#{version}/#{target}/#{test_type}/#{hardware}")
end

Then /^(?:|I )should find element "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_selector(text)
    else
      assert page.has_selector?(text)
    end
  end
end

Then /^(?:|I )should not find element "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_no_selector(text)
    else
      assert page.has_no_selector?(text)
    end
  end
end
