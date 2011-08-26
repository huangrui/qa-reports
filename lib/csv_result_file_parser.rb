
class CSVResultFileParser

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
    FasterCSV.parse(io, @FCSV_settings) {|row| parse_row(row) }
    @features
  end

  private

  RESULT_MAPPING = [
    MeegoTestCase::PASS,
    MeegoTestCase::FAIL,
    MeegoTestCase::NA 
  ]

  def parse_row(row)
    #TODO: Field names should be harmonized with result.xml
    [0, 1].each { |field| raise ParseError.new("unknown"), "Incorrect file format" unless row[field] }

    feature   = row[0].toutf8.strip
    test_case = row[1].toutf8.strip
    comment   = row[2].try(:toutf8).try(:strip) || ""
    
    raise "Invalid test case result" if row.fields(:pass, :fail, :na).count("1") != 1
    result    = RESULT_MAPPING[row.fields(:pass, :fail, :na).index("1")]

    @features[feature] ||= {}
    @features[feature][test_case] = {:name => test_case, :result => result, :comment => comment}
  end
end