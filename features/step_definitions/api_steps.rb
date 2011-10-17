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

Given /^I have sent a request with optional parameter "([^"]*)" with value "([^"]*)" via the REST API$/ do |opt, val|
  Given %{the client sends a request with optional parameter "#{opt}" with value "#{val}" via the REST API}
  # Needed in order to get different time stamps for current - previous matching
  sleep 1
end

def api_import( params )
  post "api/import", params
end

When /^the client sends file "([^"]*)" via the REST API$/ do |file|
  # @default_api_opts defined in features/support/hooks.rb
  api_import @default_api_opts.merge( "report.1" => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml") )
  response.should be_success
end

When /^the client sends file "([^"]*)" via the REST API with RESTful parameters$/ do |file|
  api_import @default_api_opts.merge("report.1" => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml"))
  response.should be_success
end

When /^the client sends reports "([^"]*)" via the REST API to test set "([^"]*)" and product "([^"]*)"$/ do |files, testset, hardware|
  data = @default_api_opts.merge({
    "testtype"        => testset,
    "hwproduct"       => hardware
  })

  files.split(',').each_with_index do |file, index|
    data["report."+(index+1).to_s] = Rack::Test::UploadedFile.new(file, "text/xml")
  end

  api_import data
  response.should be_success
end

When /^the client sends reports "([^"]*)" via the new REST API to test set "([^"]*)" and product "([^"]*)"$/ do |files, testset, hardware|
  data = @default_new_api_opts.merge({
    "testset"        => testset,
    "hardware"       => hardware
  })

  files.split(',').each_with_index do |file, index|
    data["report."+(index+1).to_s] = Rack::Test::UploadedFile.new(file, "text/xml")
  end

  api_import data
  response.should be_success
end

When /^the client sends file with attachments via the REST API$/ do
  api_import @default_api_opts.merge({
      "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"),
      "report.2"        => Rack::Test::UploadedFile.new("features/resources/bluetooth.xml", "text/xml"),
      "attachment.1"    => Rack::Test::UploadedFile.new("public/images/ajax-loader.gif", "image/gif"),
      "attachment.2"    => Rack::Test::UploadedFile.new("public/images/icon_alert.gif", "image/gif"),
  })
  response.should be_success
end

When /^the client sends a request with string value instead of a files via the REST API$/ do
    api_import @default_api_opts.merge("report.1" => "Foo!")
end

When /^the client sends a request without file via the REST API$/ do
  @default_api_opts.delete("report.1")
  api_import @default_api_opts
  response.should be_success
end

When /^the client sends a request without parameter "target" via the REST API$/ do
  @default_api_opts.delete("target")
  api_import @default_api_opts
  response.should be_success
end

When /^the client sends a request with extra parameter "([^"]*)" via the REST API$/ do |extra|
  # TODO: this step should be replaced with the step defined below
  post "/api/import?auth_token=foobar&release_version=1.2&target=Core&testtype=automated&hardware=N900&" + extra, {
      "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml")
  }
  response.should be_success

end

When /^the client sends a request with optional parameter "([^"]*)" with value "([^"]*)" via the REST API$/ do |opt, val|
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
