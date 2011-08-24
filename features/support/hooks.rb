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


  @testcase_template = {
  :name => "dummy testcase", :result => 1, :comment => "dummy"
  }
  @feature_template = {
    :name => "dummy feature", :meego_test_cases_attributes => [@testcase_template]
  }
  @report_template = {
    :release_version => "1.2",
    :target => "Core",
    :testset => "Sanity",
    :product => "N900",
    :tested_at => "2011-12-30 23:45:59",
    :published => true,
    :title => "dummy title",
    :uploaded_files => "dummy_file.csv",
    :features_attributes => [@feature_template]
  }
end

After do
  #visit destroy_user_session_path
  #DatabaseCleaner.clean
  Rails.cache.clear
end
