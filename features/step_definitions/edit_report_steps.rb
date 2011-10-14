
def find_testcase_row(tcname)
  namecell = page.find(".testcase_name", :text => tcname)
  namecell.find(:xpath, "ancestor::tr")
end

Given %r/^the report for "([^"]*)" exists on the service$/ do |file|
  Given "I am an user with a REST authentication token"

  # @default_api_opts defined in features/support/hooks.rb
  api_import @default_api_opts.merge( "report.1" => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml") )
  response.should be_success
end


When %r/^(?:|I )edit the report "([^"]*)"$/ do |report_string|
  version, target, test_type, product = report_string.downcase.split('/')
  report = MeegoTestSession.first(:conditions =>
   {"releases.name" => version, "profiles.label" => target, :product => product, :testset => test_type}, :include => [:release, :profile],
   :order => "tested_at DESC, created_at DESC")
  raise "report not found with parameters #{version}/#{target}/#{product}/#{test_type}!" unless report
  visit("/#{version}/#{target}/#{test_type}/#{product}/#{report.id}/edit")
end

And %r/^(?:|I )delete the test case "([^"]*)"/ do |testcase|
  tc = MeegoTestCase.find_by_name(testcase)
  with_scope("#testcase-#{tc.id}") do
    click_link "Remove"
  end
end

When %r/^(?:|I )click the element "([^"]*)" for the test case "([^"]*)"$/ do |element, test_case|
  find(:xpath, "//tr[contains(.,'#{test_case}')]").find(element).click
end

When %r/^(?:|I )delete all test cases/ do
  When %{I follow "See all"}

  session = MeegoTestSession.find(current_url.split('/')[-2])
  session.meego_test_cases.each do |tc|
    with_scope("#testcase-#{tc.id}") do
      click_link "Remove"
    end
  end
end

Then %r/^the report should not contain a detailed test results section/ do
  Then %{I should not see "Detailed Test Results"}
end

result_value = {'Pass' => '1', 'Fail' => '-1', 'N/A' => '0'}

When %r/^I change the test case result of "([^"]*)" to "([^"]*)"$/ do |tc, result|
  row = find_testcase_row(tc)
  row.find('.testcase_result').click()
  row.select(result, :from => "test_case[result]")
end

Then %r/^the result of test case "([^"]*)" should be "([^"]*)"$/ do |tc, result|
  actual = find_testcase_row(tc).find(".testcase_result .content")
  actual.should have_content(result), "Expected text case '#{tc}' result to be '#{result}'\nGot result '#{actual.text}'\n"
end

When %r/^I change the test case comment of "([^"]*)" to "([^"]*)"$/ do |tc, comment|
  row = find_testcase_row(tc)
  cell = row.find('.testcase_notes')
  cell.click()
  cell.fill_in "test_case[comment]", :with => comment
end

