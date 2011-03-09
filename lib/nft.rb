

module MeasurementUtils

  def calculate_outline(s)
    o = MeasurementOutline.new
    total = 0
    values = []
    s.each do |v|
      val = v.value
      o.minval = unless o.minval.nil? then [o.minval, val].min else val end 
      o.maxval = unless o.maxval.nil? then [o.maxval, val].max else val end
      total += val
      values << val
    end
    o.avgval = total.to_f / values.size
    values.sort!
    o.median = values[values.size/2]
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

  def series_json(s, maxsize=40)
    s = shorten_series(s, maxsize)
    "[" + s.map{|v| shorten_value(v)}.join(",") + "]"
  end

  def shorten_value(v)
    s = v.value.to_s
    s = s[0..-3] if s.end_with? ".0"
    s
  end
end

class MeasurementOutline
  attr_accessor :minval, :maxval, :avgval, :median
end
