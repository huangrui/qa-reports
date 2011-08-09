

module MeasurementUtils

  XAXIS_FACTORS = {
    "ms" => 1000,
    "s" => 1,
    "min" => 1.0/60.0,
    "h" => 1.0/60.0/60.0
  }.freeze

  def format_value(v, significant=3)
    s = sprintf("%.#{significant}f",v.to_f)
    (pre,post) = s.split('.')
    after = significant - pre.size
    if after > 0
      "#{pre}.#{post[0,after]}"
    else
      pre
    end
  end

  def calculate_outline(s, interval)
    o = MeasurementOutline.new
    total = 0
    values = []
    s.each do |v|
      val = v['value'].try(:to_f)
      o.minval = unless o.minval.nil? then [o.minval, val].min else val end 
      o.maxval = unless o.maxval.nil? then [o.maxval, val].max else val end
      total += val
      values << val
    end
    o.avgval = total.to_f / values.size
    values.sort!
    size = values.size
    if size > 0 && (size % 2) == 0
      o.median = (values[size/2] + values[size/2-1])/2.0
    else
      o.median = values[size/2]
    end
    
    if interval
      # Time span from intervals (only ms used, thus dividing to get seconds)
      timespan = (s.length-1) * interval.to_f / 1000
    else
      # Time span of measurement series in seconds
      last = Time.parse(s[s.length-1]['timestamp'])
      first = Time.parse(s[0]['timestamp'])
      timespan = last - first
    end

    if timespan < 10
      # 0 - 9999 ms
      o.interval_unit = "ms"
    elsif timespan < 10000
      # 0 - 9999 s
      o.interval_unit = "s"
    elsif timespan < 600000
      # 0 - 9999 min
      o.interval_unit = "min"
    else
      o.interval_unit = "h"
    end
    o
  end

  def shorten_series(s, maxsize)
    if s.size <= maxsize
      values = s
    else
      values = []
      ratio = maxsize.to_f / s.size
      c = 1.0
      s.each do |v|
        if c >= 1.0
          values << v
          c -= 1.0
        end
        c += ratio
      end
      values
    end
  end

  def shortened_indices(size, maxsize)
    indices = (0..size-1)
    if size <= maxsize
      indices
    else
      ratio = maxsize.to_f / size
      c = 1.0
      indices.select do
        filter = if c >= 1.0
          c -= 1.0
          true
        else
          false
        end
        c += ratio
        filter
      end
    end
  end

  def series_json(s, maxsize=40)
    s = shorten_series(s, maxsize)
    json = "[" + s.map{|v| shorten_value(v)}.join(",") + "]"
    if json.length >= 255
      new_max = maxsize*255/json.length
      series_json(s, new_max-1)
    else
      json
    end
  end

  def series_json_withx(m, interval_unit, maxsize=200)
    s = m.element_children
    indices = shortened_indices(s.size, maxsize)

    factor = XAXIS_FACTORS[interval_unit]
    if m['interval']
      # Dividing since interval is currently always in milliseconds and
      # the factors are for seconds
      xaxis = (0..s.size-1).map {|i| i * m['interval'].to_f * factor / 1000}
    else
      xaxis = (0..s.size-1).map {|i| ((Time.parse(s[i]['timestamp'])-Time.parse(s[0]['timestamp']))*factor).to_i}
    end

    "[" + indices.map{|i| "[#{xaxis[i]},#{s[i]['value']}]"}.join(",") + "]"
  end

  def shorten_value(v)
    s = v['value']
    s = s[0..-3] if s.end_with? ".0"
    s2 = sprintf("%.1e", v['value'])
    if s2.length < s.length
      s2
    else
      s
    end
  end
end

class MeasurementOutline
  attr_accessor :minval, :maxval, :avgval, :median, :interval_unit
end
