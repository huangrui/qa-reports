When /^(?:|I )edit the report "([^"]*)"/ do |report|
  When %{I view the report "#{report}"}
  And %{I click to edit the report}
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

