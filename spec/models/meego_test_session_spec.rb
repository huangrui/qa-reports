require 'spec_helper'

describe MeegoTestSession do

  def build_feature(name)
    feature = FactoryGirl.build :feature_wo_test_cases
    feature.name = name
    feature
  end

  describe "Without Test Cases" do
    it "should return 0 for Run rate, pass rate and executed pass rate" do
      report = FactoryGirl.build(:test_report_wo_features, :tested_at => '2011-09-01')
      report.features << FactoryGirl.build(:feature_wo_test_cases)
      report.run_rate.should == 0
      report.pass_rate.should == 0
      report.pass_rate_executed.should == 0
    end
  end

  describe "With Passed, Failed, N/A and Measured Test Cases" do
    it "should calculate Run rate, pass rate and executed pass rate" do
      report = FactoryGirl.build(:test_report_wo_features, :tested_at => '2011-09-01')
      report.features << FactoryGirl.build(:feature_wo_test_cases)
      report.features.first.meego_test_cases <<
        FactoryGirl.build_list(:test_case, 8 , :result => MeegoTestCase::PASS) <<
        FactoryGirl.build_list(:test_case, 5 , :result => MeegoTestCase::FAIL) <<
        FactoryGirl.build_list(:test_case, 4 , :result => MeegoTestCase::NA)   <<
        FactoryGirl.build_list(:test_case, 7 , :result => MeegoTestCase::MEASURED)
      report.save!
      report.run_rate.should == (8.0 + 5.0 + 7.0) / (8.0 + 5.0 + 4.0 + 7.0)
      report.pass_rate.should == (8.0) / (8.0 + 5.0 + 4.0)
      report.pass_rate_executed.should == (8.0) / (8.0 + 5.0)
    end
  end

  describe "Merging test sessions" do

    it "should merge all existing features with any new features" do
      report = FactoryGirl.build(:test_report_wo_features, :tested_at => '2011-09-01')

      feature = build_feature "FeatureA"
      feature.meego_test_cases << FactoryGirl.build(:test_case, :name => "Foo", :result => MeegoTestCase::PASS)
      report.features << feature

      feature = build_feature "FeatureB"
      feature.meego_test_cases << FactoryGirl.build(:test_case, :name => "Foo", :result => MeegoTestCase::FAIL)

      report.save!

      merge_hash = {:features_attributes => [
        {:name => "FeatureA", :meego_test_cases_attributes => [
          {:name => "Foo", :result => MeegoTestCase::FAIL}]},
        {:name => "FeatureB", :meego_test_cases_attributes => [
          {:name => "Foo", :result => MeegoTestCase::NA}]}
        ]}

      report.merge! merge_hash
      report.save!

      report.features.to_a.find{|f| f.name == "FeatureA"}.test_cases.to_a.find{|tc| tc.name == "Foo"}.result.should == MeegoTestCase::FAIL
      report.features.to_a.find{|f| f.name == "FeatureB"}.test_cases.to_a.find{|tc| tc.name == "Foo"}.result.should == MeegoTestCase::NA

      report.features.to_a.find{|f| f.name == "FeatureA"}.should have(1).test_cases
      report.features.to_a.find{|f| f.name == "FeatureB"}.should have(1).test_cases
    end
  end

end
