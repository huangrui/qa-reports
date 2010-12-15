module ReportParser
  def self.parse_features(features)
    begin
      features.split(',').map{|item| Integer(item.strip)}
    rescue
      [features]
    end      
  end
end