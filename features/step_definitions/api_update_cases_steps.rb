When /^the client updates the report with id (\d+) with file "([^\"]*)" via the REST API$/ do |id, file|
  post "/api/update/#{id}?auth_token=foobar", {
      "report"          => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml")
  }
  response.should be_success
end
