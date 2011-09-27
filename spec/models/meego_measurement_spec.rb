require 'spec_helper'

describe MeegoMeasurement do

  describe "Without Test Cases" do
    it "should return 1 nft index if the target is reached" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => 5, :target => 5, :failure => nil)
      measurement.nft_index2.should == 1.0
    end

    it "should return 1 nft index if the target is exceeded (by default exceeding means getting under target)" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => 4, :target => 5, :failure => nil)
      measurement.nft_index2.should == 1.0
    end

    it "should return correct nft index if the target is not met" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => 6, :target => 5, :failure => nil)
      measurement.nft_index2.should == (5.0 / 6.0)
    end

    it "should return 0 nft index if the value is zero" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => 0, :target => -1, :failure => nil)
      measurement.nft_index2.should == 0.0
    end
  end

end
