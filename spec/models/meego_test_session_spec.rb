require 'spec_helper'

describe MeegoTestSession do

  describe "renaming testsets" do

    it "should change title accordingly" do
      report = FactoryGirl.build :test_report, :testset => "foo", :title => "Test report for foo in 2011"
      report.testset = "bar"
      report.title.should == "Test report for bar in 2011"
    end

    it "should not affect title when testset name is not there" do
      report = FactoryGirl.build :test_report, :testset => "foo", :title => "Test report in 2011"
      report.testset = "bar"
      report.title.should == "Test report in 2011"
    end
  end

  describe "renaming products" do

    it "should change title accordingly" do
      report = FactoryGirl.build :test_report, :product => "N900", :title => "Test report for N900 in 2011"
      report.product = "N950"
      report.title.should == "Test report for N950 in 2011"
    end

    it "should not affect title when product name is not there" do
      report = FactoryGirl.build :test_report, :product => "Pinetrail", :title => "Test report in 2011"
      report.product = "N950"
      report.title.should == "Test report in 2011"
    end
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
    it "should calucalate Run rate, pass rate and executed pass rate" do
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
end
