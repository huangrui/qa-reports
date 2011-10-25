require 'spec_helper'

def build_feature
  feature = FactoryGirl.build :feature_wo_test_cases
  feature.meego_test_cases << FactoryGirl.build(:test_case, :name => "Foo", :result => MeegoTestCase::PASS, :comment => "foocomment")
  feature
end

describe Feature do

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
                    {:name => "Far", :result => MeegoTestCase::NA, :comment => "farcomment"}]

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
#:meego_test_cases_attributes=>[{:comment=>"[[4021]]", :result=>1, :name=>"Browser gesture support"}, {:comment=>"", :result=>1, :name=>"Open 2 tabs to surf 2 websites contains flash plugin"}, {:comment=>"Not support in meego 1.1 release.", :result=>0, :name=>"Browsing website over 3G (WCDMA)"}], :name=>"Fennec browser"}, {:meego_test_cases_attributes=>[{:comment=>"SIM function is not implemented yet.", :result=>0, :name=>"Receive a call, accept the call, terminate this call (phonesim, GSM & WCDMA) (GSM and WCDMA cannot be covered until real modem supported,Will use phonesim to test before real modem support)"}, {:comment=>"[[5856]]", :result=>-1, :name=>"Check call history"}, {:comment=>"SIM function is not implemented yet.", :result=>0, :name=>"Receive one call, reject this call without accepting the call(phonesim, GSM & WCDMA)(GSM and WCDMA cannot be covered until real modem supported,Will use phonesim to test before real modem support)"}, {:comment=>"[[5856]]", :result=>-1, :name=>"Display PhoneBook"}, {:comment=>"B
