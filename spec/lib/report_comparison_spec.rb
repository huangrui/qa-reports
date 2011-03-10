require 'spec_helper'
require 'report_comparison'
require 'rspec/rails/mocks.rb'

class ReportComparisonSpec < ActiveSupport::TestCase
  
  describe ReportComparison do
    before(:each) do
      user = User.new({
          :email => "test@test.com",
          :password => "foobar",
          :name => "TestUser"
      })
      @session1 = MeegoTestSession.import({
          :author => user,
          :title => "Test1",
          :target => "Core",
          :testtype => "Sanity",
          :hwproduct => "N900",
          :version_label_id => 1
      }, [File.new("spec/fixtures/sim1.xml")], user)

      @session2 = MeegoTestSession.import({
          :author => user,
          :title => "Test1",
          :target => "Core",
          :testtype => "Sanity Testing",
          :hwproduct => "N900",
          :version_label_id => 1
      }, [File.new("spec/fixtures/sim2.xml")], user)
    end

    it "should compare two reports and list changed tests" do
      comparison = ReportComparison.new()
      comparison.add_pair(@session1.hwproduct, @session1, @session2)
      results = comparison.changed_test_cases
      results[0].name.should == "SMOKE-SIM-Query_SIM_card_status"
      results[1].name.should == "SMOKE-SIM-Get_IMSI"
      results[2].name.should == "SMOKE-SIM-Disable_PIN_query"
      results[3].name.should == "SMOKE-SIM-Query_Service_Provider_name"      
      results.length.should == 4
      comparison.changed_to_fail.should == "-2"
      comparison.changed_to_pass.should == "+1"
      comparison.new_passing.should == "0"
      comparison.new_na.should == "0"
      comparison.new_failing.should == "1"
    end

    it "should be able to compare two different reports and group items" do
      comparison = ReportComparison.new()
      comparison.add_pair(@session1.hwproduct, @session1, @session2)
      groups = comparison.groups
      groups.map{|group| group.name}.should == ['SIM']
      group = groups.first
      first = group.row("SMOKE-SIM-Query_SIM_card_status").value(@session1.hwproduct)
      first.left.name.should == first.right.name
      first.changed.should == true
      group.changed.should == true
    end

    it "should be able to compare two similar reports and group items" do
      comparison = ReportComparison.new()
      comparison.add_pair(@session1.hwproduct, @session1, @session1)
      groups = comparison.groups
      groups.map{|group| group.name}.should == ['SIM']
      group = groups.first
      first = group.row("SMOKE-SIM-Query_SIM_card_status").value(@session1.hwproduct)
      first.left.name.should == first.right.name
      first.changed.should == false
      group.changed.should == false
    end

    it "should be able to add reports into multiple columns" do
      comparison = ReportComparison.new()
      comparison.add_pair("column1", @session1, @session1)
      comparison.add_pair("column2", @session1, @session2)
      groups = comparison.groups
      groups.map{|group| group.name}.should == ['SIM']
      group = groups.first
      column1 = group.row("SMOKE-SIM-Query_SIM_card_status").value("column1")
      column1.left.name.should == column1.right.name
      column1.changed.should == false
      column2 = group.row("SMOKE-SIM-Query_SIM_card_status").value("column2")
      column2.left.name.should == column2.right.name
      column2.changed.should == true
      group.changed.should == true
    end
  end
end
