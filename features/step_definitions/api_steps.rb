Given /^I am an user with a REST authentication token$/ do
  Given %{I have one user "John Restless" with email "resting@man.net" and password "secretpass" and token "foobar"}
end

Given /^I have sent a request with optional parameter "([^"]*)" with value "([^"]*)" via the REST API$/ do |opt, val|
  Given %{the client sends a request with optional parameter "#{opt}" with value "#{val}" via the REST API}
end

When /^the client sends file "([^"]*)" via the REST API$/ do |file|
  post "/api/import?auth_token=foobar", {
      "report"          => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml"),
      "release_version" => "1.2",
      "target"          => "Core",
      "testtype"        => "automated",
      "hwproduct"       => "N900"
  }
  response.should be_success
end

When /^the client sends file "([^"]*)" via the REST API with RESTful parameters$/ do |file|
  post "/api/import?auth_token=foobar&release_version=1.2&target=Core&testtype=automated&hwproduct=N900", {
      "report"          => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml")
  }
  response.should be_success
end

When /^the client sends reports "([^"]*)" via the REST API to test type "([^"]*)" and hardware "([^"]*)"$/ do |files, testtype, hardware|
  data = {
      "release_version" => "1.2",
      "target"          => "Core",
      "testtype"        => testtype,
      "hwproduct"       => hardware
  }
  files.split(',').each_with_index{|file, index|
    data["report."+(index+1).to_s] = Rack::Test::UploadedFile.new(file, "text/xml")
  }
  post "/api/import?auth_token=foobar", data
  response.should be_success  
end


When /^the client sends file with attachments via the REST API$/ do
  post "/api/import?auth_token=foobar", {
      "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"),
      "report.2"        => Rack::Test::UploadedFile.new("features/resources/bluetooth.xml", "text/xml"),
      "attachment.1"    => Rack::Test::UploadedFile.new("public/images/ajax-loader.gif", "image/gif"),
      "attachment.2"    => Rack::Test::UploadedFile.new("public/images/icon_alert.gif", "image/gif"),
      "release_version" => "1.2",
      "target"          => "Core",
      "testtype"        => "automated",
      "hwproduct"       => "N900"
  }
  response.should be_success
end

When /^the client sends a request with string value instead of a files via the REST API$/ do
    post "/api/import?auth_token=foobar", {
      "report.1"        => "Foo!",
      "release_version" => "1.2",
      "target"          => "Core",
      "testtype"        => "automated",
      "hwproduct"       => "N900"
  }
end

When /^the client sends a request without file via the REST API$/ do
  post "/api/import?auth_token=foobar", {
      "release_version" => "1.2",
      "target"          => "Core",
      "tested_at"       => "20101130",
      "testtype"        => "automated",
      "hwproduct"       => "N900"
  }
  response.should be_success
end

When /^the client sends a request without parameter "target" via the REST API$/ do
  post "/api/import?auth_token=foobar", {
      "report"     => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"),
      "testtype"     => "automated",
      "hwproduct"    => "N900"
  }
  response.should be_success
end

When /^the client sends a request with extra parameter "([^"]*)" via the REST API$/ do |extra|
  post "/api/import?auth_token=foobar&release_version=1.2&target=Core&testtype=automated&hwproduct=N900&" + extra, {
      "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml")
  }
  response.should be_success

end

When /^the client sends a request with optional parameter "([^"]*)" with value "([^"]*)" via the REST API$/ do |opt, val|
  post "/api/import?auth_token=foobar&release_version=1.2&target=Core&testtype=automated&hwproduct=N900", {
    "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"),
    opt               => val
  }
  response.should be_success

end

When /I view the latest report "([^"]*)"$/ do |report_string|
  version, target, test_type, hardware = report_string.downcase.split('/')
  report = MeegoTestSession.first(:order => "id DESC", :conditions =>
   {:release_version => version, :target => target, :hwproduct => hardware, :testtype => test_type}
  )
  raise "report not found with parameters #{version}/#{target}/#{hardware}/#{test_type}!" unless report
  visit("/#{version}/#{target}/#{test_type}/#{hardware}/#{report.id}")
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
