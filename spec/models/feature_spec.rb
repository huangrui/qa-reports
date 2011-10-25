require 'spec_helper'

describe Feature do

  def build_feature
    feature = FactoryGirl.build :feature_wo_test_cases
    feature.meego_test_cases << FactoryGirl.build(:test_case, :name => "Foo", :result => MeegoTestCase::PASS, :comment => "foocomment")
    feature
  end

  describe "Merging new test cases to feature" do
    it "merging new test case" do
      feature = build_feature
      test_case    = {:name => "Bar", :result => MeegoTestCase::PASS, :comment => "barcomment"}
      feature_hash = {:meego_test_cases_attributes => [test_case]}

      feature.merge!(feature_hash)
      feature.should have(2).meego_test_cases
    end

    it "merging existing test case" do
      feature = build_feature
      test_case    = {:name => "Foo", :result => MeegoTestCase::FAIL, :comment => "changedcomment"}
      feature_hash = {:meego_test_cases_attributes => [test_case]}

      feature.merge!(feature_hash)
      feature.should have(1).meego_test_cases
      feature.meego_test_cases.select{|tc| tc.name == "Foo"}.first.result.should == MeegoTestCase::FAIL
    end

    it "merging several test cases including existing ones" do
      feature = build_feature
      test_cases = [{:name => "Foo", :result => MeegoTestCase::FAIL, :comment => "changedcomment"},
                    {:name => "Bar", :result => MeegoTestCase::PASS, :comment => "barcomment"},
                    {:name => "Far", :result => MeegoTestCase::NA,   :comment => "farcomment"}]

      feature_hash = {:meego_test_cases_attributes => test_cases}
      feature.merge!(feature_hash)
      feature.should have(3).meego_test_cases
      tc = feature.meego_test_cases.select{|tc| tc.name == "Foo"}.first
      tc.result.should  == MeegoTestCase::FAIL
      tc.comment.should == "changedcomment"
    end

    it "merging existing test case with empty comment" do
      feature = build_feature
      test_case    = {:name => "Foo", :result => MeegoTestCase::FAIL, :comment => ""}
      feature_hash = {:meego_test_cases_attributes => [test_case]}

      feature.merge!(feature_hash)
      feature.should have(1).meego_test_cases
      tc = feature.meego_test_cases.select{|tc| tc.name == "Foo"}.first
      tc.result.should  == MeegoTestCase::FAIL
      tc.comment.should == ""
    end
  end
end
