Before do
  @default_api_opts = {
    "auth_token"      => "foobar",
    "release_version" => "1.2",
    "target"          => "Core",
    "testtype"        => "automated",
    "hwproduct"       => "N900",
    "tested_at"       => "2010-1-1",
    "report.1"        => Rack::Test::UploadedFile.new("features/resources/sim.xml", "text/xml")
  }

  @default_new_api_opts = @default_api_opts.merge({
    "testset"        => "automated",
    "product"         => "N900",
  })
  @default_new_api_opts.delete("testtype")
  @default_new_api_opts.delete("hwproduct")

  @hide_api_opts = {
    "auth_token"      => "foobar",
    "release_version" => "1.2",
    "target"          => "Core",
    "testtype"        => "automated",
  }
end
