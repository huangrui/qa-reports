require 'nft'

class XMLResultFileParser
  include MeasurementUtils

  def parse(io)
    features = {}

    doc = Nokogiri::XML(io) { |config| config.strict }
    doc.css('set').each do | set |
      feature = set['feature'] || "N/A"
      features[feature] ||= {}

      set.css('case').each { |test_case| tc = parse_test_case(test_case); features[feature][tc[:name]] = tc }
      features.delete(feature) if features[feature].empty?
    end

    features
  end

  private

  RESULT_MAPPING = {
    "pass" => MeegoTestCase::PASS,
    "fail" => MeegoTestCase::FAIL,
    "na"   => MeegoTestCase::NA
  }

  def parse_test_case(test_case)
    {
      :name                               => test_case['name'],
      :result                             => RESULT_MAPPING[test_case['result'].downcase] || MeegoTestCase::NA,
      :comment                            => test_case['comment'] || "",
      :source_link                        => test_case['vcsurl']  || "",
      :measurements_attributes            => parse_measurements(test_case),
      :serial_measurements_attributes     => parse_serial_measurements(test_case)
    }
  end

  def parse_measurements(test_case)
    test_case.xpath('./measurement').map do |measurement| 
      {
        :name       => measurement['name'],
        :value      => measurement['value'].try(:to_f),
        :unit       => measurement['unit'],
        :target     => measurement['target'].try(:to_f),
        :failure    => measurement['failure'].try(:to_f),

        #TODO: Throw away and order by id
        :sort_index => 0
      }
    end
  end

  def parse_serial_measurements(test_case)
    test_case.css('series').map do | series |
      outline = calculate_outline(series.css('measurement'), series['interval'])
      {
        :name          => series['name'],
        :short_json    => series_json(series.element_children, maxsize=40),
        :long_json     => series_json_withx(series, outline.interval_unit, maxsize=200),
        :unit          => series['unit'],
        :interval_unit => outline.interval_unit,

        :min_value    => outline.minval,
        :max_value    => outline.maxval,
        :avg_value    => outline.avgval,
        :median_value => outline.median,

        #TODO: Throw away and order by id
        :sort_index   => 0
      }
    end
  end
end

