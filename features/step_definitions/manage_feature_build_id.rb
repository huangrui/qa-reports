 And /^want to see build details$/ do
 	find(:xpath, "//a[@id='detailed_case' and @class = 'see_the_same_build_button sort_btn']").click
 end

 Then /^"([^"]*)" should have results "([^"]*)" and "([^"]*)"$/ do |name, result1, result2|
 	namerow = all(:xpath, "//table[@class='detailed_results build']//tr[@class='testcase' and .//td[@class='testcase_name' and .='#{name}']]")
 	namerow.count.should == 1
 	results = namerow[0].all("td.testcase_result")
 	results.count.should == 2
 	results[0].text.should == result1
 	results[1].text.should == result2
end
