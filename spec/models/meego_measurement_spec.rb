require 'spec_helper'

describe MeegoMeasurement do

  describe "By default, if there is no fail limit, bigger is better. Measurement index = value/target." do
    it "should return 1 index if the target is met" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => 5, :target => 5, :failure => nil)
      measurement.index.should == 1.0
    end

    it "should return 1 index if the target is exceeded" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => 530, :target => 5, :failure => nil)
      measurement.index.should == 1.0
    end

    it "should return correct index if the target is not met" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => 4, :target => 5, :failure => nil)
      measurement.index.should == (4.0 / 5.0)
    end

    it "should return nil index if the target is zero" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => -1, :target => 0, :failure => nil)
      measurement.index.should == nil
    end

    it "should return nil index if there is no target" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => 10, :target => nil, :failure => nil)
      measurement.index.should be_nil
    end

    it "should return 0 index if there is no value but there is a target (test case has N/A status)" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => nil, :target => 5, :failure => nil)
      measurement.index.should == 0.0
    end

    it "should return 0 if value is 0" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => 0, :target => 5, :failure => nil)
      measurement.index.should == 0.0
    end
  end

  describe "For certain units, like s (seconds) the index calculation is reversed. So that the index = target/value (value must be below target to success)" do
    it "should return 1 index if the target is met" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "s", :value => 10, :target => 10, :failure => nil)
      measurement.index.should == 1.0
    end

    it "should return 1 index if the target is exceeded" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "s", :value => 6, :target => 10, :failure => nil)
      measurement.index.should == 1.0
    end

    it "should return correct index if the target is not met" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "s", :value => 13, :target => 10, :failure => nil)
      measurement.index.should == 10.0/13.0
    end

    it "should return 1 if value is 0" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "s", :value => 0, :target => 10, :failure => nil)
      measurement.index.should == 1
    end
  end

  describe "Fail limit is used as the preferred method to determine how measurement index is calculated" do
    it "should use value/target when fail limit < target (more is better)" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "s", :value => 2, :target => 10, :failure => 6)
      measurement.index.should == 2.0/10.0
    end

    it "should use target/value when fail limit > target (less is better)" do
      measurement = FactoryGirl.build(:meego_measurement, :unit => "fbar", :value => 12, :target => 7, :failure => 10)
      measurement.index.should == 7.0/12.0
    end
  end

end
