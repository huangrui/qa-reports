require 'spec_helper'
require 'report_parser'

describe ReportParser do
  it "should parse comma separated list of features separately" do
    result = ReportParser::parse_features("1234, 2345")
    result.length.should == 2
    result.should == [1234, 2345]
  end

  it "should create feature N/A when no feature is not available" do
    result = ReportParser::parse_features("")
    result.should == ["N/A"]
  end

  it "should return string containing commas as a single item" do
    result = ReportParser::parse_features("Feature, Funny feature")
    result.length.should == 1
    result.should == ["Feature, Funny feature"]
  end

  it "should return string containing numbers and commas as a single item" do
    result = ReportParser::parse_features("1234, Feature, Funny feature")
    result.should == ["1234, Feature, Funny feature"]
  end

  it "should return string containing strings starting with numbers and commas as a single item" do
    result = ReportParser::parse_features("3D Graphics OpenGL/GLES,2D graphics")
    result.should == ["3D Graphics OpenGL/GLES,2D graphics"]
  end

end
