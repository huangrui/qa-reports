Given /^the report for "([^"]*)" exists on the service$/ do |file|
  Given %{I have one user "John Restless" with email "resting@man.net" and password "secretpass" and token "foobar"}

  # @default_api_opts defined in features/support/hooks.rb
  api_import @default_api_opts.merge( "report.1" => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml") )
  response.should be_success
end


When /^(?:|I )edit the report "([^"]*)"$/ do |report_string|
  version, target, test_type, product = report_string.downcase.split('/')
  report = MeegoTestSession.first(:conditions =>
   {"version_labels.normalized" => version, :target => target, :product => product, :testset => test_type}, :include => :version_label,
   :order => "tested_at DESC, created_at DESC")
  raise "report not found with parameters #{version}/#{target}/#{product}/#{test_type}!" unless report
  visit("/#{version}/#{target}/#{test_type}/#{product}/#{report.id}/edit")
end

And /^(?:|I )delete the test case "([^"]*)"/ do |testcase|
  tc = MeegoTestCase.find_by_name(testcase)
  with_scope("#testcase-#{tc.id}") do
    click_link "Remove"
  end
end

When /^(?:|I )click the element "([^"]*)" for the test case "([^"]*)"$/ do |element, test_case|
  find(:xpath, "//tr[contains(.,'#{test_case}')]").find(element).click
end

When /^(?:|I )delete all test cases/ do
  When %{I follow "See all"}

  session = MeegoTestSession.find(current_url.split('/')[-2])
  session.meego_test_cases.each do |tc| 
    with_scope("#testcase-#{tc.id}") do
      click_link "Remove"
    end
  end
end

Then /^the report should not contain a detailed test results section/ do
  Then %{I should not see "Detailed Test Results"}
end

