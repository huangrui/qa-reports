Given /^there's an existing report$/ do
  report = FactoryGirl.build(:test_report_wo_features, :tested_at => '2011-09-01')
  report.features << FactoryGirl.build(:feature_wo_test_cases)
  report.features.first.meego_test_cases <<
    FactoryGirl.build(:test_case, :name => 'Test Case 1', :result => MeegoTestCase::PASS, :comment => 'This comment should be used as a template') <<
    FactoryGirl.build(:test_case, :name => 'Test Case 2', :result => MeegoTestCase::PASS, :comment => 'This comment should be overwritten with empty comment')

  report.save!
end

Given /^I create a new test report with same test cases$/ do
  RESULT_CSV = 'Category,Check points,Notes (bugs),Pass,Fail,N A
Bluetooth,Test Case 1,,1,0,0
Bluetooth,Test Case 2,,0,1,0'

  tmp = Tempfile.new('result_file')
  tmp << RESULT_CSV
  file = ActionDispatch::Http::UploadedFile.new(:tempfile => tmp, :filename => 'result.csv')
  report_attributes = MeegoTestSession.first.attributes.merge(:tested_at => '2011-09-02')
  report_attributes[:result_files_attributes] = [{:file => file, :attachment_type => :result_file}]

  report = ReportFactory.new.build(report_attributes)
  report.save!
  report.prev_session.features.count.should == 1
end

Then /^I should see the test case comments from the previous test report if the result hasn't changed$/ do
  report = MeegoTestSession.find_by_tested_at('2011-09-02')
  visit report_path(report)
  click_link_or_button('+ see 1 passing tests')
  find(:xpath, "//tr[td[@class='testcase_name'][p='Test Case 1']]").should have_content('This comment should be used as a template')
  find(:xpath, "//tr[td[@class='testcase_name'][p='Test Case 2']]").should have_no_content('This comment should be overwritten with empty comment')
end