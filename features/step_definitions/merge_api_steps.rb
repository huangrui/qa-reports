require 'tempfile'
include MeegoTestCaseHelper

CSV_HEADERS =
  [
    "Feature",
    "Test Case",
    "Pass",
    "Fail",
    "NA",
    "Comment",
    "Measurement Name",
    "Value",
    "Unit",
    "Target",
    "Failure"
  ]

def generate_csv(report)
  rows = []

  report.features.each do |f|
    f.meego_test_cases.each do |tc|
      rows << {
        :feature  => f.name,
        :testcase => tc.name,
        :pass     => tc.result ==  1 ? 1 : 0,
        :fail     => tc.result == -1 ? 1 : 0,
        :na       => tc.result ==  0 ? 1 : 0,
        :measured => tc.result ==  2 ? 1 : 0,
        :comment  => tc.comment
      }
    end
  end
#Feature,Test Case,Pass,Fail,NA,Comment,Measurement Name,Value,Unit,Target,Failure

  FasterCSV.generate(:col_sep => ',') do |csv|
    csv << CSV_HEADERS
    rows.each do |row|
      csv << [row[:feature], row[:testcase], row[:pass], row[:fail], row[:na], row[:comment]]
    end
  end
end

def generate_report(table)
  report = FactoryGirl.build(:test_report_wo_features)
  features  = {}
  table.hashes.each do |hash|
    feature_name = hash[:feature_name]
    feature      = features[feature_name]
    if not feature
      features[feature_name] = feature = FactoryGirl.build(:feature_wo_test_cases, :name => hash[:feature_name])
    end
    feature.meego_test_cases << FactoryGirl.build(:test_case, :name   => hash[:testcase_name],
                                  :result => MeegoTestCaseHelper::txt_to_result(hash[:result]))
    report.features << feature
  end
  report
end

# default opts should have multiple files
def default_api_merge_opts
  {:auth_token   => "foobar",
   :result_files => [
     Rack::Test::UploadedFile.new("features/resources/short1.csv", "text/csv"),
     Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"),
     Rack::Test::UploadedFile.new("features/resources/bluetooth.xml", "text/xml")]}
end

def api_merge(params, id=MeegoTestSession.last.id)
  post "api/merge/#{id}", params
end

Given /^I have created a test report$/ do
  FactoryGirl.create(:test_report)
end

When /^I merge with the latest report using multiple files$/ do
  api_merge default_api_merge_opts
end

When %r/^I merge the result file "([^"]*)" with report having id "([^"]*)"$/ do |file, id|
  assert file.present?, "filename is missing"
  params = default_api_merge_opts
  params[:result_files] = [Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml")]
  api_merge params, id
end


When %r/^I merge with the latest report using result file "([^"]*)"$/ do |file|
  assert file.present?, "filename is missing"
  params = default_api_merge_opts
  params[:result_files] = [Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml")]
  api_merge params
end

When /^I merge with the latest report without defining a result file$/ do
  params = default_api_merge_opts
  params.delete(:result_files)
  api_merge params
end

When /^I merge with the latest report without defining an auth token$/ do
  params = default_api_merge_opts
  params.delete(:auth_token)
  api_merge params
end

When /^I merge with the latest report using multiple files including an invalid file$/ do
  params = default_api_merge_opts
  params[:result_files] << Rack::Test::UploadedFile.new("features/resources/invalid.csv", "text/csv")
  api_merge params
end

When /^I merge with a non\-existing report using result file "([^"]*)"$/ do |file|
  Then "I merge the result file \"#{file}\" with report having id \"1234567890\""
end

Then %r/^the API responds with an error about "([^"]*)"$/ do |error|
  Then %{the REST result "errors" contains "#{error}"}
end

Then /^the API responds ok$/ do
  response.should be_success, "Expected: 200\nGot: #{response.code}, #{response.body}"
end

When /^I merge with the latest report with an invalid auth token$/ do
  params = default_api_merge_opts
  params[:auth_token] = "invalidtoken"
  api_merge params
end

When /^I merge with the latest report using string as file parameter$/ do
  params = default_api_merge_opts
  params[:result_files] << "not_a_file"
  api_merge params
end

Given /^I have a report with$/ do |table|
  report = generate_report table
  report.save
end

When /^I merge with$/ do |table|
  csv = generate_csv generate_report(table)
  file = Tempfile.new ["tempresultcsv",".csv"]
  file << csv
  file.flush
  params = default_api_merge_opts
  params[:result_files] = [Rack::Test::UploadedFile.new(file.path, "text/csv")]
  api_merge params
end

And /^I should see the report contain$/ do |table|
  report = MeegoTestSession.last
  test_cases = report.test_cases.to_a.map {|test_case| [test_case.feature.name, test_case.name, test_case.result] }
  expected_cases = table.hashes.map do |hash|
    [hash[:feature_name], hash[:testcase_name], MeegoTestCaseHelper::txt_to_result(hash[:result])]
  end
  puts test_cases
  puts expected_cases
  test_cases.sort.should == expected_cases.sort
end
