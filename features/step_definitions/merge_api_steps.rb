include MeegoTestCaseHelper

Given /^I have a report with$/ do |table|
  report = FactoryGirl.build(:test_report_wo_features)
  features  = {}
  table.hashes.each do |hash|
    feature_name = hash[:feature_name]
    feature      = features[feature_name]
    if not feature
      features[feature_name] = feature = FactoryGirl.build(:feature_wo_test_cases, :name => hash[:feature_name])
    end
    feature.meego_test_cases << FactoryGirl.build(:test_case, :name   => hash[:testcase_name],
                                  :result => MeegoTestCaseHelper::txt_to_result(hash[:result]))
    report.features << feature
  end
  report.save
end

When /^I merge with$/ do |table|
  table.hashes.each do |hash|
    puts hash.inspect #TODO: remove
  end
  pending # express the regexp above with the code you wish you had
end

Then /^the API responds ok$/ do
  Then %{the REST result "ok" is "1"}
end

Then /^I should see it contain$/ do |table|
  table.hashes.each do |hash|
    puts hash.inspect #TODO: remove
  end

  pending # express the regexp above with the code you wish you had
end
