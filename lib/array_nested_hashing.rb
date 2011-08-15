class Array

  # For an array A of class C with methods a, b, c
  # H = A.to_nested_hash [:a, :b]                   ... H[a][b] returns C
  # H = A.to_nested_hash [:a, :b], :unique => false ... H[a][b] returns [C, C, ...]
  # H = A.to_nested_hash [:a, :b], :map => :c       ... H[a][b] returns C.c

  def to_nested_hash(key_names, opt = {})
    opt = {:unique => true}.merge(opt)

    last_key = key_names.pop

    self.inject({}) do |result, item|
      current = result
      key_names.each do |key|
        key_value = item.send(key)
        current = (current[key_value] ||= {})
      end

      last_key_value = item.send(last_key)
      end_item = opt.has_key?(:map) ? item.send(opt[:map]) : item
      if opt[:unique]
        current[last_key_value] = end_item
      else
        (current[last_key_value] ||= []) << end_item
      end

      result
    end
  end
end