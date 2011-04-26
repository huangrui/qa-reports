require 'spec_helper'
require 'result_file_parser'

describe ResultFileParser do

  describe "Parsing valid csv file with two features and five test cases" do

    before(:each) do
      @result_file_csv = <<-END
        Feature,Test case,Notes (bugs),Pass,Fail,N/A
        Feature 1,Test Case 1,comment 1: OK,1,0,0
        Feature 1,Test Case 2,comment 2: FAIL,0,1,0
        Feature 2,Test Case 3,comment 3: NA,,,1
        Feature 2,Test Case 4,comment 4: FAIL,0,1,0
        Feature 1,Test Case 5,comment 5: FAIL,0,1,0
      END

      # Result format should be
      # [
      #   {:feature => "Feature 1", :meego_test_cases => {
      #      [{:name => "Test Case 1", :result => 1, :comment "OK"   },
      #       {:name => "Test Case 2", :result => -1, :comment "FAIL"},
      #       {:name => "Test Case 5", :result => -1, :comment "FAIL }
      #      ] } 
      #   },
      #
      #   {:feature => "Feature 2", :meego_test_cases => {
      #      [{:name => "Test Case 3", :result => 0, :comment "NA"   },
      #       {:name => "Test Case 4", :result => -1, :comment "FAIL"},
      #      ] }
      #   }
      # ]

      @test_sets = ResultFileParser.parse_csv(StringIO.new(@result_file_csv))

      @features = @test_sets.map { |test_set| test_set[:feature]}

      @test_cases = {}
      @test_sets.each do |test_set|
        @test_cases[test_set[:feature]] = test_set[:meego_test_cases]
      end

      # Usage = @test_cases["Feature"]["Testcase"][:field]
      @test_cases.each do |feature, test_cases|
        @test_cases[feature] = test_cases.group_by { |test_case| test_case[:name] }
        @test_cases[feature].each { |name, tc| @test_cases[feature][name] = @test_cases[feature][name][0] }
      end
    end

    it "should have two features" do
      @features.count.should == 2
    end

    it "should have 'Feature 1'" do
      @features.include?("Feature 1").should == true
    end

    it "should have 'Feature 2'" do
      @features.include?("Feature 2").should == true
    end

    it "should have five test cases" do
      test_case_count = @test_sets.map { |test_set| test_set[:meego_test_cases].count }.reduce(:+)
      test_case_count.should == 5
    end

    ###############################
    # FEATURE 1
    ###############################
    describe "Feature 1" do
      before(:each) do
        @fea = "Feature 1"
      end

      it "should have three test cases" do
        @test_cases[@fea].keys.count.should == 3
      end

      it "should have test case 'Feature 1, Test Case 1'" do
        @test_cases[@fea].keys.include?("Test Case 1").should == true
      end

      it "should have test case 'Feature 1, Test Case 2'" do
        @test_cases[@fea].keys.include?("Test Case 2").should == true
      end

      it "should have test case 'Feature 1, Test Case 2'" do
        @test_cases[@fea].keys.include?("Test Case 5").should == true
      end

      describe "Feature 1, Test Case 1" do
        before(:each) do
          @tc = "Test Case 1"
        end

        it "should have result PASS" do
          @test_cases[@fea][@tc][:result].should == MeegoTestCase::PASS
        end

        it "should have comment 'comment: OK'" do
          @test_cases[@fea][@tc][:comment].should == "comment 1: OK"
        end
      end

      describe "Feature 1, Test Case 2" do
        before(:each) do
          @tc = "Test Case 2"
        end

        it "should have result FAIL" do
          @test_cases[@fea][@tc][:result].should == MeegoTestCase::FAIL
        end

        it "should have comment 'comment: OK'" do
          @test_cases[@fea][@tc][:comment].should == "comment 2: FAIL"
        end
      end

      describe "Feature 1, Test Case 5" do
        before(:each) do
          @tc = "Test Case 5"
        end

        it "should have result FAIL" do
          @test_cases[@fea][@tc][:result].should == MeegoTestCase::FAIL
        end

        it "should have comment 'comment: OK'" do
          @test_cases[@fea][@tc][:comment].should == "comment 5: FAIL"
        end
      end
    end

    ###############################
    # FEATURE 2
    ###############################
    describe "Feature 2" do
      before(:each) do
        @fea = "Feature 2"
      end

      it "should have two test cases" do
        @test_cases[@fea].keys.count.should == 2
      end

      it "should have test case 'Feature 2, Test Case 3'" do
        @test_cases[@fea].keys.include?("Test Case 3").should == true
      end

      it "should have test case 'Feature 2, Test Case 4'" do
        @test_cases[@fea].keys.include?("Test Case 4").should == true
      end

      describe "Feature 2, Test Case 3" do
        before(:each) do
          @tc = "Test Case 3"
        end

        it "should have result NA" do
          @test_cases[@fea][@tc][:result].should == MeegoTestCase::NA
        end

        it "should have comment 'comment: OK'" do
          @test_cases[@fea][@tc][:comment].should == "comment 3: NA"
        end
      end

      describe "Feature 2, Test Case 4" do
        before(:each) do
          @tc = "Test Case 4"
        end

        it "should have result NA" do
          @test_cases[@fea][@tc][:result].should == MeegoTestCase::FAIL
        end

        it "should have comment 'comment: OK'" do
          @test_cases[@fea][@tc][:comment].should == "comment 4: FAIL"
        end
      end
    end

  end

end
