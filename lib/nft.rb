

module MeasurementUtils

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
    size = values.size
    if size > 0 && (size % 2) == 0
      o.median = (values[size/2] + values[size/2+1])/2.0
    else
      o.median = values[size/2]
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
    "[" + s.map{|v| shorten_value(v)}.join(",") + "]"
  end

  def series_json_withx(m, maxsize=200)
    s = m.measurements
    indices = shortened_indices(s.size, maxsize)
    
    if m.interval
      xaxis = indices.map {|i| i*m.interval}
    else
      xaxis = indices.map {|i| s[i].timestamp}
    end

    "[" + indices.map{|i| "[#{xaxis[i]},#{s[i].value}]"}.join(",") + "]"
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
