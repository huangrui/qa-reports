require 'spec_helper'
require 'meego_test_session'

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

end
