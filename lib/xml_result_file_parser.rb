require 'nft'

class XMLResultFileParser

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
        @test_cases[feature][test_case['name']][:has_nft] = true
        @test_cases[feature][test_case['name']][:measurements_attributes] ||= []
        @test_cases[feature][test_case['name']][:measurements_attributes] << parse_measurement(element)
      # elsif element.name == 'series'
      #   @test_cases[feature][test_case['name']][:has_nft] = true
      #   @test_cases[feature][test_case['name']][:serial_measurements_attributes] ||= []
      #   @test_cases[feature][test_case['name']][:serial_measurements_attributes] << parse_measurement_series(element)
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

      #TODO: Drop this
      :sort_index => 0
    }
  end

  def parse_measurement_series(measurement_series)
    # outline = MeasurementUtils.calculate_outline(m.measurements,m.interval)
    # {
    #   :name       => m.name,
    #   :sort_index => nft_index,
    #   :short_json => series_json(m.measurements, maxsize=40),
    #   :long_json  => series_json_withx(m, outline.interval_unit, maxsize=200),
    #   :unit       => m.unit,
    #   :interval_unit => outline.interval_unit,

    #   :min_value    => outline.minval,
    #   :max_value    => outline.maxval,
    #   :avg_value    => outline.avgval,
    #   :median_value => outline.median
    # }
  end
end

