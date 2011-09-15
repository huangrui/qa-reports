require 'spec_helper'
require 'index'

describe Index do

  before do
    @release = FactoryGirl.create(:release)
    FactoryGirl.create(:profile, :label => "B Profile", :normalized => "b", :sort_order => 2)
    FactoryGirl.create(:profile, :label => "A Profile", :normalized => "a", :sort_order => 1)
    FactoryGirl.create(:profile, :label => "C Profile", :normalized => "c", :sort_order => 3)
    FactoryGirl.create(:test_report, :release_id => @release.id, :testset => "A Testset", :product => "A Product", :target => "c")
    FactoryGirl.create(:test_report, :release_id => @release.id, :testset => "B Testset", :product => "B Product", :target => "b")
    FactoryGirl.create(:test_report, :release_id => @release.id, :testset => "C Testset", :product => "C Product", :target => "a")
    @index   = Index.new
  end

  it "should list profiles" do
    expected = {
      :release => @release.name,
      :profiles => [
        {
          :name => "A Profile"
        },
        {
          :name => "B Profile"
        },
        {
          :name => "C Profile"
        }
      ]
    }

    result = @index.find(@release)
    result.should == expected
  end

end
