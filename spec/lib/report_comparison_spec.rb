require 'spec_helper'

describe ReportComparison do

  before(:each) do
    @latest_report = mock_model(MeegoTestSession)
    @latest_report.stub!(:passed).and_return(34)
    @latest_report.stub!(:failed).and_return(12)
    @latest_report.stub!(:na).and_return(8)

    @previous_report = mock_model(MeegoTestSession)
    @previous_report.stub!(:passed).and_return(23)
    @previous_report.stub!(:failed).and_return(8)
    @previous_report.stub!(:na).and_return(3)

    @new_pass_count = mock_model(MeegoTestCase)
    @new_pass_count.stub!(:verdict).and_return(1)
    @new_pass_count.stub!(:count).and_return(8)

    @new_fail_count = mock_model(MeegoTestCase)
    @new_fail_count.stub!(:verdict).and_return(-1)
    @new_fail_count.stub!(:count).and_return(4)

    @new_na_count = mock_model(MeegoTestCase)
    @new_na_count.stub!(:verdict).and_return(0)
    @new_na_count.stub!(:count).and_return(2)
  end

  describe "with new passed cases" do
    before(:each) do
      MeegoTestCase.stub!(:find_by_sql).and_return([@new_na_count])
      @comparison = ReportComparison.new(@latest_report, @previous_report)
    end

    it "should know the amount of new passed cases" do
      @comparison.new_passing.should == 0
    end

    it "should know the amount of new failed cases" do
      @comparison.new_failing.should == 0
    end

    it "should know the amount of new na cases" do
      @comparison.new_na.should == @new_na_count.count
    end
  end

  describe "with new passed, failed and na cases" do
    before(:each) do
      MeegoTestCase.stub!(:find_by_sql).and_return([@new_pass_count, @new_na_count, @new_fail_count])
      @comparison = ReportComparison.new(@latest_report, @previous_report)
    end

    it "should know the amount of new passed cases" do
      @comparison.new_passing.should == @new_pass_count.count
    end

    it "should know the amount of new failed cases" do
      @comparison.new_failing.should == @new_fail_count.count
    end

    it "should know the amount of new na cases" do
      @comparison.new_na.should == @new_na_count.count
    end
  end

end

#def MeegoTestSession.unsafe_import(attributes, files, user)
#  attr             = attributes.merge!({:uploaded_files => files})
#  result           = MeegoTestSession.new(attr)
#  result.tested_at = result.tested_at || Time.now
#  result.import_report(user, true)
#  result.save_uploaded_files
#  result.save(:validate => false)
#  result
#end
#
#class ReportComparisonSpec < ActiveSupport::TestCase
  #
#  describe ReportComparison do
#    before(:each) do
#
#      @file1 = File.new("spec/fixtures/sim1.xml")
#      @file2 = File.new("spec/fixtures/sim2.xml")
#      @file1.stub!(:original_filename).and_return("sim1.xml")
#      @file2.stub!(:original_filename).and_return("sim2.xml")
#
#      user = User.new({
#          :email => "test@test.com",
#          :password => "countbar",
#          :name => "TestUser"
#      })
#      @session1 = MeegoTestSession.unsafe_import({
#          :author => user,
#          :title => "Test1",
#          :target => "Core",
#          :testtype => "Sanity",
#          :hwproduct => "N900",
#          :release_version => "1.2"
#      }, [@file1], user)
#
#      @session2 = MeegoTestSession.unsafe_import({
#          :author => user,
#          :title => "Test1",
#          :target => "Core",
#          :testtype => "Sanity Testing",
#          :hwproduct => "N900",
#          :release_version => "1.2"
#      }, [@file2], user)
#    end
#
#    it "should compare two reports and list changed tests" do
#      comparison = ReportComparison.new()
#      comparison.add_pair(@session1.hwproduct, @session1, @session2)
#      results = comparison.changed_test_cases
#      results[0].name.should == "SMOKE-SIM-Query_SIM_card_status"
#      results[1].name.should == "SMOKE-SIM-Get_IMSI"
#      results[2].name.should == "SMOKE-SIM-Disable_PIN_query"
#      results[3].name.should == "SMOKE-SIM-Query_Service_Provider_name"
#      results.length.should == 4
#      comparison.changed_to_fail.should == "-2"
#      comparison.changed_to_pass.should == "+1"
#      comparison.new_passing.should == "0"
#      comparison.new_na.should == "0"
#      comparison.new_failing.should == "1"
#    end
#
#    it "should be able to compare two different reports and group items" do
#      comparison = ReportComparison.new()
#      comparison.add_pair(@session1.hwproduct, @session1, @session2)
#      groups = comparison.groups
#      groups.map{|group| group.name}.should == ['SIM']
#      group = groups.first
#      first = group.row("SMOKE-SIM-Query_SIM_card_status").value(@session1.hwproduct)
#      first.left.name.should == first.right.name
#      first.changed.should == true
#      group.changed.should == true
#    end
#
#    it "should be able to compare two similar reports and group items" do
#      comparison = ReportComparison.new()
#      comparison.add_pair(@session1.hwproduct, @session1, @session1)
#      groups = comparison.groups
#      groups.map{|group| group.name}.should == ['SIM']
#      group = groups.first
#      first = group.row("SMOKE-SIM-Query_SIM_card_status").value(@session1.hwproduct)
#      first.left.name.should == first.right.name
#      first.changed.should == false
#      group.changed.should == false
#    end
#
#    it "should be able to add reports into multiple columns" do
#      comparison = ReportComparison.new()
#      comparison.add_pair("column1", @session1, @session1)
#      comparison.add_pair("column2", @session1, @session2)
#      groups = comparison.groups
#      groups.map{|group| group.name}.should == ['SIM']
#      group = groups.first
#      column1 = group.row("SMOKE-SIM-Query_SIM_card_status").value("column1")
#      column1.left.name.should == column1.right.name
#      column1.changed.should == false
#      column2 = group.row("SMOKE-SIM-Query_SIM_card_status").value("column2")
#      column2.left.name.should == column2.right.name
#      column2.changed.should == true
#      group.changed.should == true
#    end
#  end
#end
