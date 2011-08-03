require 'parse_error'

# class XMLResultFileParser

#   def parse(io)
#     test_cases = {}

#     doc = Nokogiri::XML(io) { |config| config.strict }
#     sets = doc.css('set')

#     sets.each do | set |
#       feature = set['feature'] || "N/A"

#       set.css('case').each do |test_case|
#         name    = test_case['name'] || ""
#         comment = test_case['comment'] || ""
#         result  = parse_test_case_result(test_case['result'])

#         test_cases[feature] ||= {}
#         test_cases[feature][name] = {:name => name, :result => result, :comment => comment}
#       end
#     end

#     test_cases
#   end

#   private

#   def parse_test_case_result(result)
#     result_mapping = { 
#       "pass" => MeegoTestCase::PASS,
#       "fail" => MeegoTestCase::FAIL,
#       "na"   => MeegoTestCase::NA
#     }

#     result_mapping[result.downcase] || MeegoTestCase::NA
#   end
# end

# class CSVResultFileParser

#   def parse(io)
#     #TODO: Field names should be harmonized with result.xml
#     test_cases = {}

#     FasterCSV.parse(io, :col_sep => ',',
#                         :headers           => true,
#                         :header_converters => :symbol,
#                         :skip_blanks => true) do |row|

#       [0, 1].each { |field| raise ParseError.new("unknown"), "Incorrect file format" unless row[field] }

#       feature = row[0] ? row[0].toutf8.strip : "N/A"
#       name    = row[1].toutf8.strip
#       comment = row[2] ? row[2].toutf8.strip : ""
#       result  = parse_test_case_result(row[:pass], row[:fail], row[:na])

#       test_cases[feature] ||= {}
#       test_cases[feature][name] = {:name => name, :result => result, :comment => comment}
#     end

#     test_cases
#   end

#   private

#   def parse_test_case_result(pass, fail, na)
#     if pass == "1" && fail != "1" && na !="1"
#       result = MeegoTestCase::PASS
#     elsif pass != "1" && fail == "1" && na !="1"
#       result = MeegoTestCase::FAIL
#     elsif pass != "1" && fail != "1" && na =="1"
#       result = MeegoTestCase::NA
#     else
#       raise "Invalid test case result"
#     end

#     result
#   end
# end