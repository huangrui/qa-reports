module ResultFileParser

  def self.parse_csv(io)
    # Skip the title row
    io.gets

    test_cases = {}
    FasterCSV.parse(io, {:col_sep => ','}) do |row|
      feature = row[0].toutf8.strip
      name    = row[1].toutf8.strip
      comment = row[2].toutf8.strip
      result  = parse_test_case_result(row[3], row[4], row[5])

      test_cases[feature] ||= {}
      test_cases[feature][name] = {:name => name, :result => result, :comment => comment}
    end

    test_cases
  end

  private

  def self.parse_test_case_result(pass, fail, na)
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