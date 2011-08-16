


When /^the client sends a updated file "([^\"]*)" with the id (\d+) via the REST API$/ do |file, report_id|
  report_id = MeegoTestSession.find(:first).id
  post "/api/update/#{report_id}?auth_token=foobar", {
      "report"          => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml")
  }
  response.should be_success
end

When "the client sends an updated result file" do
  When %{the client sends a updated file "sim.xml" with the id 1 via the REST API}
end

And "I have sent a file with NFT results" do
  And %{I have sent the file "serial_result.xml" via the REST API}
end

And /^I have sent the file "([^\"]*)" via the REST API$/ do |file|
  post "/api/import?auth_token=foobar", {
      "report"          => Rack::Test::UploadedFile.new("features/resources/#{file}", "text/xml"),
      "release_version" => "1.2",
      "target"          => "Netbook",
      "testset"         => "automated",
      "hardware"        => "N900"
  }
end

When /^the client sends several updated files with the id (\d+) via the REST API$/ do |report_id|
  report_id = MeegoTestSession.find(:first).id
  post "/api/update/#{report_id}?auth_token=foobar", {
      "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim_new.xml", "text/xml"),
      "report.2"        => Rack::Test::UploadedFile.new("features/resources/bluetooth.xml", "text/xml"),
  }
  response.should be_success
end

When /^the client sends 1 updated valid file, and 1 invalid file with the id (\d+) via the REST API$/ do |report_id|
  report_id = MeegoTestSession.find(:first).id
  post "/api/update/#{report_id}?auth_token=foobar", {
      "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim_new.xml", "text/xml"),
      "report.2"        => Rack::Test::UploadedFile.new("features/resources/invalid.xml", "text/xml"),
  }
  response.should be_success
end

When /^I view the [\w\ ]*report$/ do
 When %{I view the report "1.2/Netbook/Automated/N900"}
end

Then "I see NFT results" do
  Then %{I should find element "#detailed_nft_results"}
  And %{I should find element "a[href='#detailed_nft_results']" within ".toc"}
end

Then "I should not see NFT results" do
  Then %{I should not find element "#detailed_nft_results"}
  And %{I should not find element "a[href='#detailed_nft_results']" within ".toc"}
end
