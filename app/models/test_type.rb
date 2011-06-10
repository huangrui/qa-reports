class TestType

  def self.has_comparison?(profile, test_type)
    @comparable_test_types ||= find_comparable_test_types
    !@comparable_test_types[profile.downcase].nil? && @comparable_test_types[profile.downcase].include?(test_type.downcase)
  end

  def self.invalidate_cache
    @comparable_test_types = nil
  end

 private

  def self.find_comparable_test_types
    @comparable_test_types = MeegoTestSession.published.select("DISTINCT target as profile, testtype").
      where("testtype LIKE '%:Testing'")

    @comparable_test_types = @comparable_test_types.group_by { |t| t.profile.downcase }
    @comparable_test_types.each do |profile, test_types|
      @comparable_test_types[profile] = test_types.map { |testtype| testtype.testtype.split(":")[0].downcase }
    end

    @comparable_test_types
  end

end