require 'spec_helper'

describe ReportGroupViewModel do

  before(:each) do
    #TODO: Don't stub class under test.

    @latest_report = MeegoTestSession.new
    @latest_report.stub!(:passed).and_return(34)
    @latest_report.stub!(:failed).and_return(12)
    @latest_report.stub!(:na).and_return(8)

    @previous_report = MeegoTestSession.new
    @previous_report.stub!(:passed).and_return(23)
    @previous_report.stub!(:failed).and_return(8)
    @previous_report.stub!(:na).and_return(3)

    @oldest_report = MeegoTestSession.new
    @oldest_report.stub!(:passed).and_return(23)
    @oldest_report.stub!(:failed).and_return(15)
    @oldest_report.stub!(:na).and_return(8)

    @latest_tc_count = Object.new
    @previous_tc_count = Object.new
    @oldest_tc_count = Object.new

    @latest_tc_count = @latest_report.passed + @latest_report.failed + @latest_report.na
    @previous_tc_count = @previous_report.passed + @previous_report.failed + @previous_report.na
    @oldest_tc_count = @oldest_report.passed + @oldest_report.failed + @oldest_report.na

     MeegoTestSession.stub_chain(:published, :where, :count).and_return(3)
    @rgvm = ReportGroupViewModel.new("release", "target", "testset", "hwproduct")
  end

  describe "Group with multiple reports" do
    before(:each) do
      MeegoTestSession.stub_chain(:published, :includes, :where, :order).and_return([@latest_report, @previous_report, @oldest_report])
      MeegoTestSession.stub_chain(:published, :includes, :where, :limit, :offset, :order).and_return([@latest_report, @previous_report, @oldest_report])
      @rgvm.stub!(:find_max_cases).and_return(@latest_tc_count)
    end

    it "should have three reports" do
      @rgvm.all_reports.should == [@latest_report, @previous_report, @oldest_report]
    end

    it "should have comparison" do
      @rgvm.has_comparison?.should == true
    end

    it "should know max number of test cases" do
      @rgvm.max_cases.should == @latest_tc_count
    end
  end

  describe "Group with one report" do
    before(:each) do
      MeegoTestSession.stub_chain(:published, :includes, :where, :order).and_return([@latest_report])
      MeegoTestSession.stub_chain(:published, :includes, :where, :limit, :offset, :order).and_return([@latest_report])
      @rgvm.stub!(:find_max_cases).and_return(@latest_tc_count)
    end

    it "should have one report" do
      @rgvm.all_reports.should == [@latest_report]
    end

    it "should not have comparison" do
      @rgvm.has_comparison?.should == false
    end
  end

end