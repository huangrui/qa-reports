module ResultFileParser

  def self.parse_xml(io)
    test_cases = {}

    doc = Nokogiri::XML(io) { |config| config.strict }
    sets = doc.css('set')

    sets.each do | set |
      feature = set['feature'] || ""

      set.css('case').each do |test_case|
        name    = test_case['name'] || ""
        comment = test_case['comment'] || ""
        result  = parse_xml_test_case_result(test_case['result'])

        test_cases[feature] ||= {}
        test_cases[feature][name] = {:name => name, :result => result, :comment => comment}
      end
    end

    test_cases
  end

  def self.parse_csv(io)
    # Skip the title row
    io.gets

    test_cases = {}
    FasterCSV.parse(io, {:col_sep => ','}) do |row|
      feature = row[0].toutf8.strip
      name    = row[1].toutf8.strip
      comment = row[2] ? row[2].toutf8.strip : ""
      result  = parse_csv_test_case_result(row[3], row[4], row[5])

      test_cases[feature] ||= {}
      test_cases[feature][name] = {:name => name, :result => result, :comment => comment}
    end

    test_cases
  end

  private

  def self.parse_xml_test_case_result(result)
    result_mapping = { 
      "pass" => MeegoTestCase::PASS,
      "fail" => MeegoTestCase::FAIL,
      "na"   => MeegoTestCase::NA
    }

    result_mapping[result.downcase] || MeegoTestCase::NA
  end

  def self.parse_csv_test_case_result(pass, fail, na)
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