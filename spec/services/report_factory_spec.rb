require 'spec_helper'
require 'report_factory'
require 'result_file_parser'

describe ReportFactory do

  class ResultFile
  end

  describe "with valid attributes" do
    before(:each) do

      @report_attributes = {
        :release_version => "1.2",
        :target => "Core",
        :testtype => "Sanity",
        :hwproduct => "N900",
        :tested_at => "2011-12-30 23:45:59",
        :uploaded_files => [@result_file1, @result_file2]
      }

      @test_cases = [
        {:name => "Test Case 1", :result => 1, :comment => "OK"   },
        {:name => "Test Case 2", :result => -1, :comment => "FAIL"},
        {:name => "Test Case 3", :result => 0, :comment => "NA"   }
      ]

      @test_sets1 = [
        {:feature => "Feature 1", :meego_test_cases_attributes => @test_cases },
        {:feature => "Feature 2", :meego_test_cases_attributes => @test_cases }
      ]

      @test_sets2 = [
        {:feature => "Feature 3", :meego_test_cases_attributes => @test_cases },
        {:feature => "Feature 4", :meego_test_cases_attributes => @test_cases }
      ]

      @result_file1 = ResultFile.new
      @result_file2 = ResultFile.new
      
      ResultFileParser.stub!(:parse_csv).and_return(@test_sets1, @test_sets2)

      @report = ReportFactory.create(@report_attributes)
    end

    it "should create a valid report with valid attributes" do
      @report.should be_valid
    end

    it "should set the report title to 'Core Test Report: N900 Sanity 2011-12-30" do
      @report.title.should == "Core Test Report: N900 Sanity 2011-12-30"
    end

    it "should set the report environment to '* Hardware: N900'" do
      @report.environment_txt == "* Hardware: N900"
    end

    it "should parse result files and set the report test cases" do
      @report.save!
      @report.meego_test_sets.count.should == 4
    end
  end
end
