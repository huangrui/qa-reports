require 'nft'

class XMLResultFileParser
  include MeasurementUtils

  def initialize
    @test_cases = {}
  end

  def parse(io)
    doc = Nokogiri::XML(io) { |config| config.strict }
    doc.css('set').each { | set | parse_test_set(set) }
    @test_cases
  end

  private

  def parse_test_set(set)
    feature = set['feature'] || "N/A"
    set.css('case').each { |test_case| parse_test_case(feature, test_case) }
  end

  def parse_test_case(feature, test_case)
    @test_cases[feature] ||= {}
    @test_cases[feature][test_case['name']] = {
      :name        => test_case['name'],
      :result      => parse_test_case_result(test_case['result']),
      :comment     => test_case['comment'] || "",
      :source_link => test_case['vcsurl']  || ""}

    parse_nft_results(feature, test_case)
  end

  def parse_test_case_result(result)
    result_mapping = { 
      "pass" => MeegoTestCase::PASS,
      "fail" => MeegoTestCase::FAIL,
      "na"   => MeegoTestCase::NA
    }

    result_mapping[result.downcase] || MeegoTestCase::NA
  end

  def parse_nft_results(feature, test_case)
    test_case.element_children.each do |element|

      if element.name == 'measurement'
        #TODO: Get rid of 'has_nft' field
        @test_cases[feature][test_case['name']][:has_nft] = true
        @test_cases[feature][test_case['name']][:measurements_attributes] ||= []
        @test_cases[feature][test_case['name']][:measurements_attributes] << parse_measurement(element)
      elsif element.name == 'series'
        @test_cases[feature][test_case['name']][:has_nft] = true
        @test_cases[feature][test_case['name']][:serial_measurements_attributes] ||= []
        @test_cases[feature][test_case['name']][:serial_measurements_attributes] << parse_measurement_series(element)
      end
    end
  end

  def parse_measurement(measurement)
    {
      :name       => measurement['name'],
      :value      => measurement['value'].try(:to_f),
      :unit       => measurement['unit'],
      :target     => measurement['target'].try(:to_f),
      :failure    => measurement['failure'].try(:to_f),

      #TODO: Thrown away and order by id
      :sort_index => 0
    }
  end

  def parse_measurement_series(measurement_series)
    outline = calculate_outline(measurement_series.element_children, measurement_series['interval'])
    {
      :name          => measurement_series['name'],
      #:short_json    => series_json(measurement_series.measurements, maxsize=40),
      #:long_json     => series_json_withx(measurement_series, outline.interval_unit, maxsize=200),
      #:unit          => measurement_series['.unit'],
      #:interval_unit => outline.interval_unit,

      :min_value    => outline.minval,
      :max_value    => outline.maxval,
      :avg_value    => outline.avgval,
      :median_value => outline.median,

      #TODO: Throw away and order by id
      :sort_index   => 0
    }
  end
end

