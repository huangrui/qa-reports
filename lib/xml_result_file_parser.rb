require 'nft'

class XMLResultFileParser
  include MeasurementUtils

  RESULT_MAPPING = {
    "pass" => MeegoTestCase::PASS,
    "fail" => MeegoTestCase::FAIL,
    "na"   => MeegoTestCase::NA
  }

  def parse(io)
    Hash[
      Nokogiri::XML(io) { |config| config.strict } .css('set').map do |set|
        [
          set['feature'] || set['name'],
          set.css('case').map do |test_case|
            raise Nokogiri::XML::SyntaxError.new("Missing test case name")               unless test_case['name'].present?
            raise Nokogiri::XML::SyntaxError.new(test_case['name'] + ": Missing result") unless test_case['result'].present?

            {
              :name                               => test_case['name'],
              :result                             => RESULT_MAPPING[test_case['result'].downcase] || MeegoTestCase::NA,
              :comment                            => test_case['comment'] || "",
              :source_link                        => test_case['vcsurl']  || "",
              :measurements_attributes            => test_case.xpath('./measurement').map do |measurement|
                {
                  :name       => measurement['name'],
                  :value      => measurement['value'].try(:to_f),
                  :unit       => measurement['unit'],
                  :target     => measurement['target'].try(:to_f),
                  :failure    => measurement['failure'].try(:to_f),

                  #TODO: Throw away and order by id
                  :sort_index => 0
                }
              end ,
              :serial_measurements_attributes     => test_case.css('series').map do | series |
                outline = calculate_outline(series.css('measurement'), series['interval'])
                {
                  :name          => series['name'],
                  :short_json    => series_json(series.element_children, maxsize=40),
                  :long_json     => series_json_withx(series, outline.interval_unit, maxsize=200),
                  :unit          => series['unit'],
                  :interval_unit => outline.interval_unit,
                  :min_value     => outline.minval,
                  :max_value     => outline.maxval,
                  :avg_value     => outline.avgval,
                  :median_value  => outline.median,

                  #TODO: Throw away and order by id
                  :sort_index    => 0
                }
              end
            }
          end .index_by { |test_case| test_case[:name] }
        ]
      end
    ].delete_if { |feature, test_cases| test_cases.empty? }
  end
end
