require 'report_comparison'

class ComparisonReport
  attr_reader :test_cases, :hardwares

  def features
    @test_cases.keys
  end

  def comparisons
    @comparisons
  end

  def result_changed?(feature, test_case)
    @comparisons.each_value do |comparison|
      return true if comparison.test_case_changed?(feature, test_case)
    end

    return false
  end

  def changed_to_pass
    @comparisons.map{|k, v| v.changed_to_pass}.reduce(:+)
  end

  def changed_from_pass
    @comparisons.map{|k, v| v.changed_from_pass}.reduce(:+)
  end

  def changed_to_fail
    @comparisons.map{|k, v| v.changed_to_fail}.reduce(:+)
  end

  def changed_to_na
    @comparisons.map{|k, v| v.changed_to_na}.reduce(:+)
  end

  def fixed_from_fail
    @comparisons.map{|k, v| v.fixed_from_fail}.reduce(:+)
  end

  def fixed_from_na
    @comparisons.map{|k, v| v.fixed_from_na}.reduce(:+)
  end

  def regression_to_fail
    @comparisons.map{|k, v| v.regression_to_fail}.reduce(:+)
  end

  def regression_to_na
    @comparisons.map{|k, v| v.regression_to_na}.reduce(:+)
  end

  def new_passing
    @comparisons.map{|k, v| v.new_passing}.reduce(:+)
  end

  def new_failing
    @comparisons.map{|k, v| v.new_failing}.reduce(:+)
  end

  def new_na
    @comparisons.map{|k, v| v.new_na}.reduce(:+)
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
    @comparisons = {}
    @hardwares.each do |hardware|
      r1 = comparison_scope.includes(:meego_test_sets, :meego_test_cases).
        test_type(test_type).hardware(hardware).latest

      r2 = comparison_scope.includes(:meego_test_sets, :meego_test_cases => :meego_test_set).
        test_type(comparison_test_type).hardware(hardware).latest

      @reports << r1 << r2
      @test_cases += r1.meego_test_cases + r2.meego_test_cases
      @comparisons[hardware] = ReportComparison.new(r1, r2)
    end

    # Group by feature
    @test_cases = @test_cases.group_by { |tc| tc.meego_test_set.feature }

    @test_cases.each_key do |feature|
      # Group by test case
      @test_cases[feature] = @test_cases[feature].group_by(&:name)

      @test_cases[feature].each_key do |test_case|
        # Group by hardware
        @test_cases[feature][test_case] = @test_cases[feature][test_case].group_by {|tc| tc.meego_test_session.hwproduct.downcase}

      end
    end
  end

end