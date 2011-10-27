require 'spec_helper'

describe Profile do
  describe "Check that searches are case insensitive" do
    it "should return the same profile despite the case in name" do
      FactoryGirl.create(:profile, :name => "Foo")
      Profile.find_by_name("foo").should == Profile.find_by_name("Foo")
    end
  end
end


