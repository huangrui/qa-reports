class TestSet

  def self.has_comparison?(release, profile, test_set)
    @comparable_test_sets ||= find_comparable_test_sets(release)
    !@comparable_test_sets[profile.downcase].nil? && @comparable_test_sets[profile.downcase].include?(test_set.downcase)
  end

  def self.invalidate_cache
    @comparable_test_sets = nil
  end

 private

  def self.find_comparable_test_sets(release)
    @comparable_test_sets = MeegoTestSession.published.release(release).joins(:release).select("DISTINCT target as profile, testset").
      where("testset LIKE '%:Testing'")

    @comparable_test_sets = @comparable_test_sets.group_by { |t| t.profile.downcase }
    @comparable_test_sets.each do |profile, test_sets|
      @comparable_test_sets[profile] = test_sets.map { |testset| testset.testset.split(":")[0].downcase }
    end

    @comparable_test_sets
  end

end