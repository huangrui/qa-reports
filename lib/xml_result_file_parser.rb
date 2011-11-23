require 'nft'

class XMLResultFileParser
  include MeasurementUtils

  def parse(io)
    condition = Nokogiri::XML(io) { |config| config.strict } .css('set')
    if condition.css('case').present?
      parse_upstream(condition)
    else
      parse_internal(condition)
    end
  end

  def parse_upstream(condition)
    condition.map do |set|
      { :set => set, :name => (set['feature'] || set['name']) }
    end .inject({}) do |features, feature|
      test_cases = parse_test_cases_upstream(feature[:set])
      (features[feature[:name]] ||= {}).merge! test_cases unless test_cases.empty?
      features
    end
  end

  def parse_test_cases_upstream(set)
    set.css('case').map do |test_case|
      raise Nokogiri::XML::SyntaxError.new("Missing test case name")               unless test_case['name'].present?
      raise Nokogiri::XML::SyntaxError.new(test_case['name'] + ": Missing result") unless test_case['result'].present?

      {
        :name                               => test_case['name'],
        :result                             => MeegoTestSession.map_result(test_case['result']),
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
  end

  def parse_internal(condition)
    condition.map do |set|
      { :set => set }
    end .inject({}) do |features, feature|
      feature[:set].css('testcase').map do |test_case|
        testcase = {test_case[:purpose] => parse_single_test_cases_internal(test_case)}
        (features[test_case[:component]] ||= {}).merge! testcase unless testcase.empty?
      end
      features
    end
  end

  def parse_single_test_cases_internal(test_case)
    raise Nokogiri::XML::SyntaxError.new("Missing test case name")               unless test_case['purpose'].present?
    raise Nokogiri::XML::SyntaxError.new(test_case['purpose'] + ": Missing result") unless test_case['result'].present?

    {
      :name                               => test_case['purpose'],
      :result                             => MeegoTestSession.map_result(test_case['result']),
      :comment                            => test_case.css('notes').text || "",
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
  end
end
