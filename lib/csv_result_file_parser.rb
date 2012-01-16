
class FasterCSV
  class Row
    def has_valid_headers?
      # Check that all required headers are there
      @valid_headers ||= (self.headers() & CSVResultFileParser::REQUIRED_CSV_FIELDS).length == CSVResultFileParser::REQUIRED_CSV_FIELDS.length
    end

    def has_valid_headers_for_et?
      # Check that all required headers are there
      @valid_headers ||= (self.headers() & CSVResultFileParser::REQUIRED_CSV_FIELDS_FOR_ET).length == CSVResultFileParser::REQUIRED_CSV_FIELDS_FOR_ET.length
    end

    def has_valid_data?
      (self[:feature] &&
       self[:test_case] &&
       self.fields(:pass, :fail, :na, :measured).count("1") == 1)
    end

    def has_valid_data_for_et?
      (self[:component] &&
       self[:name] &&
       self[:status])
    end
  end
end

class CSVResultFileParser
  # Public since accessed from FasterCSV as well. The code does not really
  # require all header fields so no need to bounce otherwise perfectly
  # functional files.
  REQUIRED_CSV_FIELDS = [
    :feature,
    :test_case,
    :pass,
    :fail,
    :na
  ]

  REQUIRED_CSV_FIELDS_FOR_ET = [
    :component,
    :name,
    :status
  ]

  def initialize
    @features = {}
    @FCSV_settings = {
      :col_sep           => ',',
      :headers           => true,
      :header_converters => :symbol,
      :skip_blanks       => true
    }
  end

  def parse(io)
    begin
      # TODO: Remove check when dropping support for version 1
      if check_et_format?(io)
        FasterCSV.parse(io, @FCSV_settings) {|row| parse_row_for_et(row) }
      else
        if format_head_size(io) >= 11 then
          FasterCSV.parse(io, @FCSV_settings) {|row| parse_row(row) }
        else
          if format_head_size(io) >= 5 then
            FasterCSV.parse(io, @FCSV_settings) {|row| parse_row_version_1(row) }
          else
            FasterCSV.parse(io, @FCSV_settings) {|row| parse_row_version_testcase_management(row) }
          end
        end
      end
    rescue NoMethodError
      raise ParseError.new("unknown"), "Incorrect file format"
    end
    @features
  end

  private

  RESULT_MAPPING = [
    MeegoTestCase::PASS,
    MeegoTestCase::FAIL,
    MeegoTestCase::NA,
    MeegoTestCase::MEASURED
  ]

  ############################################################################
  # TODO: Begin removing here when dropping support for version 1
  #####

  def format_head_size(io)
    first_line = io.readline
    io.rewind

    # Check the header row length - the new version has 11 columns. Later
    # on we will not require all of those to be present, but for now
    # there has to be some differences so we can determine the version
    first_line.split(',').length
  end

  def check_et_format?(io)
    first_line = io.readline
    io.rewind
    unless first_line["Component"].nil? && first_line["component"].nil?
      return true
    else
      return false
    end
  end

  def parse_row_version_1(row)
    #TODO: Field names should be harmonized with result.xml
    [0, 1].each { |field| raise ParseError.new("unknown"), "Incorrect file format" unless row[field] }

    feature   = row[0].toutf8.strip
    test_case = row[1].toutf8.strip
    comment   = row[2].try(:toutf8).try(:strip) || ""

    raise ParseError.new("unknown"), "Invalid test case result" if row.fields(:pass, :fail, :na).count("1") != 1
    result    = RESULT_MAPPING[row.fields(:pass, :fail, :na).index("1")]

    @features[feature] ||= {}
    @features[feature][test_case] = {:name => test_case, :result => result, :comment => comment}
  end

  #####
  # TODO: End removing here
  ############################################################################

  ############################################################################
  # New parse method for intel testcase management
  #####

  def parse_row_version_testcase_management(row)
    [0, 1, 3].each { |field| raise ParseError.new("unknown"), "Incorrect file format" unless row[field] }

    feature   = row[0].toutf8.strip
    test_case = row[1].toutf8.strip
    comment   = row[2].try(:toutf8).try(:strip) || ""

    result    = case
                when row[3] == "Passed"  then MeegoTestCase::PASS
                when row[3] == "Failed"  then MeegoTestCase::FAIL
                when row[3] == "Blocked" then MeegoTestCase::NA
                else -2
                end

    unless result == -2
      @features[feature] ||= {}
      @features[feature][test_case] = {:name => test_case, :result => result, :comment => comment}
    end
  end

  #####
  # End intel parse
  ############################################################################

  def parse_row(row)
    # Check the headers - this is done for each row (since we want to parse
    # the file row by row), but naturally only the first check matters
    raise ParseError.new("unknown"), "Incorrect file format. Check CSV headers" unless row.has_valid_headers?

    # Check that we have a feature, a test case and some result
    raise ParseError.new("unknown"), "Incorrect file format. Feature or test case missing, or more than one or no result set for a case" unless row.has_valid_data?

    feature  = row[:feature].toutf8.strip
    testcase = row[:test_case].toutf8.strip

    @features[feature] ||= {}
    @features[feature][testcase] = {
      :name                    => testcase,
      :comment                 => row[:comment].try(:toutf8).try(:strip) || "",
      :measurements_attributes => parse_measurements(row) || [],
      :result                  => RESULT_MAPPING[row.fields(:pass, :fail, :na, :measured).index("1")]
    }
  end

  def parse_measurements(row)
    if not row[:measurement_name].nil? then
      # Note: unlike XML, the CSV parser returns nil for a completely missing
      # value. The XML approach puts a zero to value/target/failure if it's
      # missing, so that's what we want to do here as well
      [{
         :name    => row[:measurement_name].toutf8.strip,
         :value   => row[:value].try(:to_f),
         :unit    => row[:unit].try(:toutf8).try(:strip) || "",
         :target  => row[:target].try(:to_f),
         :failure => row[:failure].try(:to_f),

         # => TODO: Throw away and order by id
         # (comment from xml result file parser)
         :sort_index => 0
       }]
    end
  end

  def parse_row_for_et(row)
    unless row[:name].nil?
      raise ParseError.new("unknown"), "Incorrect file format. Check CSV headers" unless row.has_valid_headers_for_et?
      raise ParseError.new("unknown"), "Incorrect file format. Component, test case name, or test case status missing" unless row.has_valid_data_for_et?

      feature = row[:component].toutf8.strip

      unless row[:description].nil?
        testcase = row[:name].toutf8.strip + ": " + row[:description].toutf8.strip
      else
        testcase = row[:name].toutf8.strip
      end

      comment = row[:comment].try(:toutf8).try(:strip) || ""

      bugs = row[:bug].try(:toutf8).try(:strip) || ""

      unless bugs.empty?
        if comment.empty?
          comment << "Bug info: " + bugs
        else
          comment << "  Bug info: " + bugs
        end
      end

      result = case
               when (row[:status].toutf8.strip.downcase == "pass") || (row[:status].toutf8.strip.downcase == "passed" )  then MeegoTestCase::PASS
               when (row[:status].toutf8.strip.downcase == "fail") || (row[:status].toutf8.strip.downcase == "failed" )  then MeegoTestCase::FAIL
               when (row[:status].toutf8.strip.downcase == "block") || (row[:status].toutf8.strip.downcase == "blocked" )  then MeegoTestCase::NA
               when row[:status].toutf8.strip.downcase == "measured" then MeegoTestCase::MEASURED
               else -10
               end

      unless result == -10
        @features[feature] ||= {}
        @features[feature][testcase] = {
          :name                    => testcase,
          :comment                 => comment,
          :measurements_attributes => parse_measurements(row) || [],
          :result                  => result
        }
      end
    else
      if row[:entitytype].empty?
        raise ParseError.new("unknown"), "Incorrect file format. Component, test case name, or test case status missing" unless row.has_valid_data_for_et?
      end
    end
  end
end
