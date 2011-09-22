require 'spec_helper'

describe MeegoTestSession do
  describe "Without Test Cases" do
    it "should return 0 for Run rate" do
      report = FactoryGirl.build(:test_report_wo_features, :tested_at => '2011-09-01')
      report.features << FactoryGirl.build(:feature_wo_test_cases)
      report.run_rate.should == 0
    end
  end

  describe "With Passed, Failed, N/A and Measured Test Cases" do
    it "should calucalate Run rate" do
      report = FactoryGirl.build(:test_report_wo_features, :tested_at => '2011-09-01')
      report.features << FactoryGirl.build(:feature_wo_test_cases)
      report.features.first.meego_test_cases <<
        FactoryGirl.build_list(:test_case, 8 , :result => MeegoTestCase::PASS) <<
        FactoryGirl.build_list(:test_case, 5 , :result => MeegoTestCase::FAIL) <<
        FactoryGirl.build_list(:test_case, 4 , :result => MeegoTestCase::NA)   <<
        FactoryGirl.build_list(:test_case, 7 , :result => MeegoTestCase::MEASURED)
      report.save!
      report.run_rate.should == (8.0 + 5.0 + 7.0) / (8.0 + 5.0 + 4.0 + 7.0)
    end
  end

end
