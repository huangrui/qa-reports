Before do
  @default_api_opts = {
    "auth_token"      => "foobar",
    "release_version" => "1.2",
    "target"          => "Core",
    "testtype"        => "automated",
    "hardware"       => "N900",
    "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml")
  }
end
