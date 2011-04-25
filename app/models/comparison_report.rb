require 'report_comparison'

class ComparisonReport
  attr_reader :test_cases, :hardwares

  def features
    @test_cases.keys
  end

  def result_changed(feature, test_case)
    results = @test_cases[feature][test_case].values.map {|tc| tc.result}
    
    (results & [results.count, MeegoTestCase::PASS]).count == results.count ||
    (results & [results.count, MeegoTestCase::FAIL]).count == results.count ||
    (results & [results.count, MeegoTestCase::NA]).count   == results.count
  end

  def changed_to_pass
    @comparisons.map(&:changed_to_pass).reduce(:+)
  end

  def changed_to_fail
    @comparisons.map(&:changed_to_fail).reduce(:+)
  end

  def changed_to_na
    @comparisons.map(&:changed_to_na).reduce(:+)
  end

  def new_passing
    @comparisons.map(&:new_passed).reduce(:+)
  end

  def new_failing
    @comparisons.map(&:new_failed).reduce(:+)
  end

  def new_na
    @comparisons.map(&:new_na).reduce(:+)
  end

  def initialize(release, profile, test_type, comparison_test_type)
    comparison_scope = MeegoTestSession.release(release).profile(profile)
    hw_scope = comparison_scope.select("DISTINCT(hwproduct) as hardware")

    @hardwares = ( 
      hw_scope.test_type(test_type) & 
      hw_scope.test_type(comparison_test_type) 
      ).map{ |row| row.hardware }

    @reports = []
    @test_cases = []
    @comparisons = []
    @hardwares.each do |hardware|
      r1 = comparison_scope.includes(:meego_test_sets, :meego_test_cases).
        test_type(test_type).hardware(hardware).latest

      r2 = comparison_scope.includes(:meego_test_sets, :meego_test_cases => :meego_test_set).
        test_type(comparison_test_type).hardware(hardware).latest

      @reports << r1 << r2
      @test_cases += r1.meego_test_cases + r2.meego_test_cases
      @comparisons << ReportComparison.new(r1, r2)
    end

    # Group by feature
    @test_cases = @test_cases.group_by { |tc| tc.meego_test_set.feature }

    @test_cases.each do |feature, test_cases|
      # Group by test case
      @test_cases[feature] = @test_cases[feature].group_by(&:name)

      @test_cases[feature].each do |test_case, test_cases|
        # Group by hardware
        @test_cases[feature][test_case] = @test_cases[feature][test_case].group_by {|tc| tc.meego_test_session.hwproduct.downcase}
      end
    end
  end

end