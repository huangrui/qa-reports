require 'spec_helper'
require 'index'

describe Index do

  before do
    TargetLabel.delete_all
    @release = FactoryGirl.create(:release)
    FactoryGirl.create(:profile, :label => "B Profile", :normalized => "b profile", :sort_order => 2)
    FactoryGirl.create(:profile, :label => "A Profile", :normalized => "a profile", :sort_order => 1)
    FactoryGirl.create(:profile, :label => "C Profile", :normalized => "c profile", :sort_order => 3)
    FactoryGirl.create(:test_report, :release_id => @release.id, :testset => "A Testset", :product => "A Product", :target => "c profile")
    FactoryGirl.create(:test_report, :release_id => @release.id, :testset => "B Testset", :product => "B Product", :target => "b profile")
    FactoryGirl.create(:test_report, :release_id => @release.id, :testset => "C Testset", :product => "C Product", :target => "a profile")
    @index   = Index.new
  end

  it "should list profiles" do
    expected = {
      :release => @release.name,
      :profiles => [
        {
          "name" => "A Profile",
          :testsets => [
            {:name => "C Testset"}
          ]
        },
        {
          "name" => "B Profile",
          :testsets => [
            {:name => "B Testset"}
          ]
        },
        {
          "name" => "C Profile",
          :testsets => [
            {:name => "A Testset"}
          ]
        }
      ]
    }

    result = @index.find(@release)
    result.to_json.should == expected.to_json
  end

end
