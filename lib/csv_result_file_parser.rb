
class CSVResultFileParser

  def initialize
    @test_cases = {}
    @FCSV_settings = {
      :col_sep => ',',
      :headers           => true,
      :header_converters => :symbol,
      :skip_blanks => true
    }
  end

  def parse(io)
    FasterCSV.parse(io, @FCSV_settings) {|row| parse_row(row) }
    @test_cases
  end

  private

  def parse_row(row)
    #TODO: Field names should be harmonized with result.xml
    [0, 1].each { |field| raise ParseError.new("unknown"), "Incorrect file format" unless row[field] }

    feature = row[0].toutf8.strip
    name    = row[1].toutf8.strip
    comment = row[2] ? row[2].toutf8.strip : ""
    result  = parse_test_case_result(row[:pass], row[:fail], row[:na])

    @test_cases[feature] ||= {}
    @test_cases[feature][name] = {:name => name, :result => result, :comment => comment}
  end

  def parse_test_case_result(pass, fail, na)
    #TODO: I guess there's a cleaner way to write this
    if pass == "1" && fail != "1" && na !="1"
      result = MeegoTestCase::PASS
    elsif pass != "1" && fail == "1" && na !="1"
      result = MeegoTestCase::FAIL
    elsif pass != "1" && fail != "1" && na =="1"
      result = MeegoTestCase::NA
    else
      raise "Invalid test case result"
    end

    result
  end
end