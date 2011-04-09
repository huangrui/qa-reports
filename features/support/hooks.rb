Before do
  @default_api_opts = {
    "auth_token"      => "foobar",
    "report"          => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml"),
    "release_version" => "1.2",
    "target"          => "Core",
    "testtype"        => "automated",
    "hwproduct"       => "N900" }
end
