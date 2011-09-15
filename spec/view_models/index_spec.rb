require 'spec_helper'
require 'index'

describe Index do

  before do
    @release = FactoryGirl.create(:release)
    @profile = FactoryGirl.create(:profile, :label => "Core")
    @index   = Index.new
  end

  it "should work" do
    expected = {
      :profiles => [
        {
          :name => "Core"
        }
      ]
    }

    result = @index.find(@release)
    result.should == expected
  end

end
