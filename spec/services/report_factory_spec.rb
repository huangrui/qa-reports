require 'spec_helper'
require 'report_factory'

describe ReportFactory do

  class ResultFile

    # .open calls Kernel.sleep, which makes it a bit painful to stub with rspec
    def open
      StringIO.new("foobar")
    end
  end

  describe "a report created with valid attributes" do
    before(:each) do

      @result_file1 = ResultFile.new
      @result_file2 = ResultFile.new

      @result_file1.stub!(:original_filename).and_return("bluetooth.xml")
      @result_file2.stub!(:original_filename).and_return("wlan.csv")

      @result_file1.stub!(:path).and_return("/var/tmp/bluetooth.xml")
      @result_file2.stub!(:path).and_return("/var/tmp/wlan.csv")

      @report_attributes = {
        :release_version => "1.2",
        :target => "Core",
        :testtype => "Sanity",
        :hardware => "N900",
        :tested_at => "2011-12-30 23:45:59",
        :uploaded_files => [@result_file1, @result_file2]
      }

      @test_cases1 = {
        "Test Case 1" => {:name => "Test Case 1", :result => 1, :comment => "OK"   },
        "Test Case 2" => {:name => "Test Case 2", :result => -1, :comment => "FAIL"},
        "Test Case 3" => {:name => "Test Case 3", :result => 0, :comment => "NA"   }
      }

      @test_cases2 = {
        "Test Case 1" => {:name => "Test Case 1", :result => -1, :comment => "FAIL"  },
        "Test Case 4" => {:name => "Test Case 4", :result => -1, :comment => "FAIL"},
        "Test Case 5" => {:name => "Test Case 5", :result => 0, :comment => "NA"   }
      }

      @results1 = { "Feature 1" =>  @test_cases1, "Feature 2" => @test_cases1 }
      @results2 = { "Feature 1" => @test_cases2, "Feature 3" => @test_cases2 }


      ResultFileParser.stub!(:parse_xml).and_return(@results1)
      ResultFileParser.stub!(:parse_csv).and_return(@results2)

      FileUtils.stub!(:move)
      @report = ReportFactory.create(@report_attributes)
      @report.author = stub_model(User)
      @report.editor = stub_model(User)
    end

    it "should be a valid report" do
      @report.should be_valid
    end

    describe "the created report" do
      before(:each) do
        @report.save!
      end

      it "should have title 'Core Test Report: N900 Sanity 2011-12-30" do
        @report.title.should == "Core Test Report: N900 Sanity 2011-12-30"
      end

      it "should have environment '* Hardware: N900'" do
        @report.environment_txt == "* Hardware: N900"
      end

      it "should have three test sets" do
        @report.meego_test_sets.count.should == 3
      end

      it "should have features 'Feature 1', 'Feature 2', 'Feature 3'" do
        ["Feature 1", "Feature 2", "Feature 3"].each do |feature|
          @report.meego_test_sets.map {|set| set.feature }.include?(feature).should == true
        end
      end

      it "should have five, three and three test cases within Features 1, 2 and 3" do
        {"Feature 1" => 5, "Feature 2" => 3, "Feature 3" => 3}.each do |feature, tc_count|
          @report.meego_test_sets.by_feature(feature).meego_test_cases.count.should == tc_count
        end
      end

      it "should have test cases 1-5 within Feature 1" do
        test_cases = @report.meego_test_sets.by_feature("Feature 1").meego_test_cases

        ["Test Case 1","Test Case 2", "Test Case 3", "Test Case 4", "Test Case 5"].each do |tc_name|
          test_cases.map{|tc| tc.name }.include?(tc_name).should == true
        end
      end

      it "should have test cases 1-3 within Feature 2" do
        test_cases = @report.meego_test_sets.by_feature("Feature 2").meego_test_cases

        ["Test Case 1","Test Case 2", "Test Case 3"].each do |tc_name|
          test_cases.map{|tc| tc.name }.include?(tc_name).should == true
        end
      end

      it "should have test cases 1,4 and 5 within Feature 3" do
        test_cases = @report.meego_test_sets.by_feature("Feature 3").meego_test_cases

        ["Test Case 1","Test Case 4", "Test Case 5"].each do |tc_name|
          test_cases.map{|tc| tc.name }.include?(tc_name).should == true
        end
      end

      describe "merged test set 'Feature 1'" do
        it "should contain the result from the latest result file" do
          test_case = @report.meego_test_sets.by_feature("Feature 1").
            meego_test_cases.by_name("Test Case 1")

          test_case.result.should == MeegoTestCase::FAIL
          test_case.comment.should == "FAIL"
        end
      end

    end
  end
end
