Given /^I am an user with a REST authentication token$/ do
  if !User.find_by_email('resting@man.net')
    FactoryGirl.create(:user, 
      :name                  => 'John Restless',
      :email                 => 'resting@man.net', 
      :password              => 'secretpass', 
      :password_confirmation => 'secretpass',
      :authentication_token  => 'foobar')
  end
end

Given "the client has sent a request with a defined test objective" do
  Given %{the client sends a request with defined test objective}  
  # Needed in order to get different time stamps for current - previous matching
  sleep 1
end

def api_import( params )
  post "api/import", params
end

When "the client sends a basic test result file" do
  When %{the client sends file "features/resources/sim.xml"}
end

When "the client sends a report with tests without features" do
  When %{the client sends file "spec/fixtures/no_features.xml"}
end

# Note: this must use the API parameters for the current API version. There
# are other methods for using deprecated parameters.
When /^the client sends file "([^"]*)"$/ do |file|
  # @default_api_opts defined in features/support/hooks.rb
  api_import @default_api_opts.merge("report.1" => Rack::Test::UploadedFile.new("#{file}", "text/xml"))
  response.should be_success
end

# The first API had hwproduct and testtype
When "the client sends a basic test result file with deprecated parameters" do
  api_import @default_version_1_api_opts.merge("report.1" => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"))
  response.should be_success
end

# The 2nd API had "hardware"
When "the client sends a basic test result file with deprecated product parameter" do
  api_import @default_version_2_api_opts.merge("report.1" => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"))
  response.should be_success
end

When /^the client sends files with attachments$/ do
  api_import @default_api_opts.merge({
      "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"),
      "report.2"        => Rack::Test::UploadedFile.new("features/resources/bluetooth.xml", "text/xml"),
      "attachment.1"    => Rack::Test::UploadedFile.new("public/images/ajax-loader.gif", "image/gif"),
      "attachment.2"    => Rack::Test::UploadedFile.new("public/images/icon_alert.gif", "image/gif"),
  })
  response.should be_success
end

When "the client sends three CSV files" do
  When %{the client sends file "features/resources/short1.csv"}
  When %{the client sends file "features/resources/short2.csv"}
  When %{the client sends file "features/resources/short3.csv"}
  # Update here, no need to have a step in the feature for this
  And %{session "short1.csv" has been modified at "2011-01-01 01:01"}
  And %{session "short2.csv" has been modified at "2011-02-01 01:01"}
  And %{session "short3.csv" has been modified at "2011-03-01 01:01"}
end

When /^the client sends a request with string value instead of a file$/ do
    api_import @default_api_opts.merge("report.1" => "Foo!")
end

When /^the client sends a request without file$/ do
  @default_api_opts.delete("report.1")
  api_import @default_api_opts
  response.should be_success
end

When /^the client sends a request without a target profile$/ do
  @default_api_opts.delete("target")
  api_import @default_api_opts
  response.should be_success
end

When "the client sends a request containing invalid extra parameter" do
  When %{the client sends a request with optional parameter "foobar" with value "1"}
end

When "the client sends a request with a defined title" do
  When %{the client sends a request with optional parameter "title" with value "My Test Report"}
end

When "the client sends a request with defined test objective" do
  When %{the client sends a request with optional parameter "objective_txt" with value "To notice regression"}
end

When /^the client sends a request with optional parameter "([^"]*)" with value "([^"]*)"$/ do |opt, val|
  api_import @default_api_opts.merge({
    "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"),
    opt               => val
  })

  response.should be_success
end

When /^I view the latest report "([^"]*)"/ do |report_string|
  version, target, test_type, product = report_string.downcase.split('/')
  report = MeegoTestSession.joins(:version_label).where(:version_labels => {:label => version}, :target => target, :product => product, :testset => test_type).order("created_at DESC").first
  raise "report not found with parameters #{version}/#{target}/#{product}/#{test_type}!" unless report
  visit("/#{version}/#{target}/#{test_type}/#{product}/#{report.id}")
end

Then /^I should be able to view the latest created report$/ do
  Then %{I view the latest report "1.2/Core/Automated/N900"}
end

Then /^I should be able to view the created report$/ do
  Then %{I view the report "1.2/Core/Automated/N900"}
end

# For uploading multiple files (sim and bluetooth)
Then /^I should see names of the two features/ do
  Then %{I should see "SIM"}
  And %{I should see "BT"}
end

# For uploading attachments
Then "I should see the uploaded attachments" do
  Then %{I should see "ajax-loader.gif" within "#file_attachment_list"}
  And %{I should see "icon_alert.gif" within "#file_attachment_list"}
end

# Checking for a feature named N/A when had cases without a feature
Then "I should see an unnamed feature section" do
  Then %{I should see "N/A" within ".feature_name"}
end

# Checking the amount of cases match when we sent the file with test
# cases without features
Then "I should see the correct amount of test cases without a feature" do
  Then %{I should see "8" within "td.total"}
end

Then "I should see the defined test objective" do
  Then %{I should see "To notice regression"}
end

Then "I should see the objective of previous report" do
  Then %{I should see the defined test objective}
end

Then "I should see the defined report title" do
  Then %{I should see "My Test Report"}
end

Then "the upload succeeds" do
  Then %{the REST result "ok" is "1"}
end

Then "the upload fails" do
  Then %{the REST result "ok" is "0"}
end

Then "the result complains about invalid file" do
  Then %{the REST result "errors" is "Request contained invalid files: Invalid file attachment for field report.1"}
end

Then "the result complains about missing file" do
  Then %{the REST result "errors|uploaded_files" is "can't be blank"}
end

Then "the result complains about missing target profile" do
  Then %{the REST result "errors|target" is "can't be blank"}
end

Then "the result complains about invalid parameter" do
  Then %{the REST result "errors" is "unknown attribute: foobar"}
end

Then /^the REST result "([^"]*)" is "([^"]*)"$/ do |key, value|
  json = ActiveSupport::JSON.decode(@response.body)
  key.split('|').each { |item| json = json[item] }
  json.should == value
end

def get_testsessionid(file)
  TestResultFile.where('path like ?', '%' + file).first.meego_test_session_id
end

And /^session "([^"]*)" has been modified at "([^"]*)"$/ do |file, date|
  tid = get_testsessionid(file)
  d = DateTime.parse(date)
  ActiveRecord::Base.connection.execute("update meego_test_sessions set updated_at = '#{d}' where id = #{tid}")
end

When /^I download "([^"]*)"$/ do |file|
  get file
end

And /^resulting JSON should match file "([^"]*)"$/ do |file1|
  json = ActiveSupport::JSON.decode(response.body)
  json[0]['qa_id'].should == get_testsessionid(file1)
  json.count.should == 1
end
