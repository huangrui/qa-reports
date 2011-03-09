

module MeasurementJSON


  def self.shorten_series(s, maxsize)
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

  def self.series_json(s, maxsize=40)
    s = shorten_series(s, maxsize)
    "[" + s.map(&shorten_value).join(",") + "]"
  end

  def self.shorten_value(v)
    s = v.to_s
    s = s[0..-3] if s.end_with? ".0"
  end
end
