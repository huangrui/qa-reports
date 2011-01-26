When /^the client sends a updated file "([^\"]*)" with the id (\d+) via the REST API$/ do |file, report_id|
  post "/api/update/#{report_id}?auth_token=foobar", {
      "report"          => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml")
  }
  response.should be_success
end

And /^I have sent the file "([^\"]*)" via the REST API$/ do |file|
  post "/api/import?auth_token=foobar", {
      "report"          => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml"),
      "release_version" => "1.2",
      "target"          => "Netbook",
      "testtype"        => "automated",
      "hwproduct"       => "N900"
  }
end

When /^the client sends several updated files with the id (\d+) via the REST API$/ do |report_id|
  post "/api/update/#{report_id}?auth_token=foobar", {
      "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim_new.xml", "text/xml"),
      "report.2"        => Rack::Test::UploadedFile.new("features/resources/bluetooth.xml", "text/xml"),
  }
  response.should be_success
end

When /^the client sends 1 updated valid file, and 1 invalid file with the id (\d+) via the REST API$/ do |report_id|
  post "/api/update/#{report_id}?auth_token=foobar", {
      "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim_new.xml", "text/xml"),
      "report.2"        => Rack::Test::UploadedFile.new("features/resources/invalid.xml", "text/xml"),
  }
  response.should be_success
end
